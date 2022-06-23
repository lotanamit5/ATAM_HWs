#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <signal.h>
#include <syscall.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/reg.h>
#include <sys/user.h>
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <assert.h>
#include <string.h>
#include "elf64.h"

#define MIN_ARG_C 3
#define MAGIC_LENGTH 4
#define ET_EXEC 2
#define SHT_SYMTAB 2
#define SHT_STRTAB 3
#define STB_GLOBAL 1

typedef enum
{
    ELF_OPEN_FAIL = -1,
    ELF_NOT_EXECUTABLE = -2,
    ELF_NOT_FOUND = -3,
    ELF_UND = -4,
    ELF_SUCCESS = 0,
} elf_res;

pid_t run_target(const char *programname)
{
    pid_t pid;

    pid = fork();

    if (pid > 0)
    {
        return pid;
    }
    else if (pid == 0)
    {
        // Allow tracing of this process
        if (ptrace(PTRACE_TRACEME, 0, NULL, NULL) < 0)
        {
            perror("ptrace");
            exit(1);
        }
        // Replace this process's image with the given program
        execl(programname, programname, NULL);
    }
    else
    {
        // fork error
        perror("fork");
        exit(1);
    }
}

void run_revivo_debugger(pid_t child_pid, unsigned long addr)
{
    int wait_status;
    struct user_regs_struct regs;
    unsigned long counter = 0;

    // Wait for child to stop on its first instruction
    wait(&wait_status);

    unsigned long data = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)addr, NULL);
    printf("DBG: Original data at 0x%lu: 0x%lu\n", addr, data);

    // Write the trap instruction 'int 3' into the address
    unsigned long data_trap = (data & 0xFFFFFFFFFFFFFF00) | 0xCC;
    ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data_trap);

    // Let the child run to the breakpoint and wait for it to reach it
    ptrace(PTRACE_CONT, child_pid, NULL, NULL);
    wait(&wait_status);

    while (!WIFEXITED(wait_status))
    {
        counter++;

        // Remove the breakpoint by restoring the previous data
        ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data);
        regs.rip -= 1;
        ptrace(PTRACE_SETREGS, child_pid, 0, &regs);

        // Call func
        if (ptrace(PTRACE_SINGLESTEP, child_pid, NULL, NULL) < 0)
        {
            perror("ptrace");
            return;
        }
        // Get return addres stored on the stack
        ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
        unsigned long long stack_addr = regs.rsp;
        unsigned long long next_addr = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)stack_addr, NULL);

        // Add breaking point at return addres- next line in c program
        unsigned long next_instr = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)next_addr, NULL);
        unsigned long next_trap = (next_instr & 0xFFFFFFFFFFFFFF00) | 0xCC;
        ptrace(PTRACE_POKETEXT, child_pid, (void *)next_addr, (void *)next_trap);

        // Let the child run to the next instruction
        ptrace(PTRACE_CONT, child_pid, NULL, NULL);
        wait(&wait_status);

        // Get return value
        ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
        unsigned long long return_value = regs.rax;
        printf("PRF:: run #%lu returned with %llu\n", counter, return_value);

        // Remove the second breakpoint by restoring the previous data
        ptrace(PTRACE_POKETEXT, child_pid, (void *)next_addr, (void *)next_instr);
        regs.rip -= 1;
        ptrace(PTRACE_SETREGS, child_pid, 0, &regs);

        // Re-add the first breakpoint
        ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data_trap);

        // Let the child run to the breakpoint and wait for it to reach it
        ptrace(PTRACE_CONT, child_pid, NULL, NULL);
        wait(&wait_status);
    }
}

int isExecutable(Elf64_Ehdr *hdr)
{
    return hdr->e_type == ET_EXEC;
}

int LoadHdr(int fd, Elf64_Ehdr *hdr)
{
    if (hdr == NULL)
        return 0;
    if (read(fd, hdr, sizeof(*hdr)) != sizeof(*hdr))
        return 0;
    if (memcmp("\x7f\x45\x4c\x46", hdr, MAGIC_LENGTH))
    {
        free(hdr);
        return 0;
    }

    return 1;
}

char *GetSectionAsString(int fd, Elf64_Shdr *Shdr)
{
    lseek(fd, Shdr->sh_offset, SEEK_SET);
    char *s = (char *)malloc(Shdr->sh_size);
    int n = read(fd, s, Shdr->sh_size);
    if (n != Shdr->sh_size)
    {
        // Could not read section
        free(s);
        return NULL;
    }
    return s;
}

int GetSectionHeader(int fd, Elf64_Ehdr *hdr, char *section_names, char *shdr_name,
                     Elf64_Shdr *shdr_to_fill)
{
    Elf64_Shdr *current_shdr = (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr));
    // Get symtab and strtab headers
    lseek(fd, hdr->e_shoff, SEEK_SET);
    int found = 0;
    for (int i = 0; i < hdr->e_shnum; i++)
    {
        if (read(fd, current_shdr, sizeof(Elf64_Shdr)) != sizeof(Elf64_Shdr))
            break; // Could not read section header
        if (!strcmp(section_names + current_shdr->sh_name, shdr_name))
        {
            memcpy(shdr_to_fill, current_shdr, sizeof(Elf64_Shdr));
            found = 1;
            break;
        }
    }
    free(current_shdr);
    return found;
}

// returns the index of the symbol in the symtab or -1 if not found
int GetSymbol(int fd, Elf64_Shdr *symtab, char *func_name, char *symbol_names, Elf64_Sym *symbol_to_fill)
{
    // Go to symbol table
    lseek(fd, symtab->sh_offset, SEEK_SET);
    // Look for func's symbol
    int num_symbols = symtab->sh_size / symtab->sh_entsize;
    for (int i = 0; i < num_symbols; i++)
    {
        int n = read(fd, symbol_to_fill, symtab->sh_entsize);
        if (n != symtab->sh_entsize)
        {
            // Could not read symbol en
            return -1;
        }
        char *temp = symbol_names + symbol_to_fill->st_name;
        if (!strcmp(temp, func_name))
        {
            return i;
        }
    }
    // The symbol is not in the symtab
    return -1;
}

int LoadShdrsNames(int fd, Elf64_Ehdr *hdr, char **shdrs_names)
{
    Elf64_Shdr *shdrs_strtab = (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr));
    // Go to section header table
    lseek(fd, hdr->e_shoff, SEEK_SET);
    // Get section header string table section header
    lseek(fd, hdr->e_shstrndx * sizeof(Elf64_Shdr), SEEK_CUR);
    if (read(fd, shdrs_strtab, sizeof(Elf64_Shdr)) != sizeof(Elf64_Shdr))
    {
        free(shdrs_strtab);
        return 0; // could not load section header string table
    }
    if ((*shdrs_names = GetSectionAsString(fd, shdrs_strtab)) == NULL)
    {
        free(shdrs_strtab);
        return 0;
    }
    free(shdrs_strtab);
    return 1;
}

// returns the index of the symbol in the symtab or -1 if not found
// fills the symbol_to_fill with the symbol found
int FindSymbol(int fd, Elf64_Ehdr *hdr, char *func_name,
               Elf64_Sym *symbol_to_fill, int is_dynamic, char *shdrs_names)
{
    int num_symbols;
    char *symbol_names;
    Elf64_Shdr *symtab, *strtab;

    symtab = (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr));
    strtab = (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr));

    char *symtab_name = is_dynamic ? ".dynsym" : ".symtab";
    char *strtab_name = is_dynamic ? ".dynstr" : ".strtab";

    // Get symtab and strtab headers
    if (!GetSectionHeader(fd, hdr, shdrs_names, symtab_name, symtab) ||
        !GetSectionHeader(fd, hdr, shdrs_names, strtab_name, strtab))
    {
        // Could not find symtab or strtab
        free(symtab);
        free(strtab);
        return -1;
    }

    if ((symbol_names = GetSectionAsString(fd, strtab)) == NULL)
    {
        free(symtab);
        free(strtab);
        return -1;
    }
    int res = GetSymbol(fd, symtab, func_name, symbol_names, symbol_to_fill);
    free(symtab);
    free(strtab);
    return res;
}

int isGlobal(int fd, Elf64_Sym *symbol_en)
{
    return ELF64_ST_BIND(symbol_en->st_info) == STB_GLOBAL;
}

#define FINISH(status)             \
    do                             \
    {                              \
        if (fd != -1)              \
            close(fd);             \
        if (hdr != NULL)           \
            free(hdr);             \
        if (symbol != NULL)        \
            free(symbol);          \
        if (shdrs_names != NULL)   \
            free(shdrs_names);     \
        if (reloc_shdr != NULL)    \
            free(reloc_shdr);      \
        if (reloc_section != NULL) \
            free(reloc_section);   \
    } while (0);                   \
    return status;

elf_res getFuncAddr(char *prog_name, char *func_name, long *func_addr)
{
    Elf64_Ehdr *hdr = NULL;
    Elf64_Sym *symbol = NULL;
    Elf64_Shdr *reloc_shdr = NULL;
    char *shdrs_names = NULL, *reloc_section = NULL;

    int fd = open(prog_name, O_RDONLY);
    if (fd == -1)
    {
        FINISH(ELF_OPEN_FAIL);
    }

    hdr = (Elf64_Ehdr *)malloc(sizeof(Elf64_Ehdr));
    if (!LoadHdr(fd, hdr))
    {
        FINISH(ELF_OPEN_FAIL);
    }

    if (!LoadShdrsNames(fd, hdr, &shdrs_names))
    {
        FINISH(ELF_OPEN_FAIL);
    }

    if (!isExecutable(hdr))
    {
        FINISH(ELF_NOT_EXECUTABLE);
    }
    symbol = (Elf64_Sym *)malloc(sizeof(Elf64_Sym));
    if (!(FindSymbol(fd, hdr, func_name, symbol, 0, shdrs_names) >= 0 ||
          FindSymbol(fd, hdr, func_name, symbol, 1, shdrs_names) >= 0))
    {
        FINISH(ELF_NOT_FOUND);
    }
    if (!isGlobal(fd, symbol))
    {
        FINISH(ELF_UND);
    }
    // FIND ADDRESS:
    if (symbol->st_shndx != SHN_UNDEF)
        *func_addr = symbol->st_value;
    else
    {
        int dyn_index = FindSymbol(fd, hdr, func_name, symbol, 1, shdrs_names);
        if (dyn_index < 0)
        {
            FINISH(ELF_NOT_FOUND);
        }

        Elf64_Shdr *reloc_shdr = (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr));
        if ((reloc_section = GetSectionAsString(fd, reloc_shdr)) == NULL)
        {
            FINISH(ELF_OPEN_FAIL);
        }
        Elf64_Rela *relocations = (Elf64_Rela *)reloc_section;
        *func_addr = relocations[dyn_index].r_offset;
    }
    FINISH(ELF_SUCCESS);
}

int main(int argc, char **argv)
{
    pid_t child_pid;
    char *func_name, *prog_name;
    long func_addr;
<<<<<<< HEAD
    // if (argc < MIN_ARG_C)
    // {
    //     fprintf(stderr, "PRF:: Not enough args");
    //     exit(1);
    // }
=======
    /*
    if (argc < MIN_ARG_C)
    {
        fprintf(stderr, "PRF:: Not enough args");
        exit(1);
    }
>>>>>>> d545d1771a474fbe039bcbc9d7b1c688d679bf48
    func_name = argv[1];
    // 'run_target' is using 'execl' so by passing 'prog_name'
    // we are passing its args aswell (they are right after him
    // in the original 'argv' array).
    prog_name = argv[2];
    */

<<<<<<< HEAD
    char *tst_prog_name = "/mnt/c/Users/lotan/VSCode/ATAM_HWs/HW4/basic_test.out";
    char *tst_func_name = "foo";
    elf_res res = getFuncAddr(tst_prog_name, tst_func_name, &func_addr);
    char *tst_func_name = "add";
    elf_res res = getFuncAddr(tst_prog_name, tst_func_name, &func_addr);
    char *tst_func_name = "printf";
    elf_res res = getFuncAddr(tst_prog_name, tst_func_name, &func_addr);

    // elf_res res = getFuncAddr(prog_name, func_name, &func_addr);
=======
    // USE TO TEST 
    char * tst_func_name = "foo";
    char * tst_prog_name = "/home/student/Desktop/ATAM/ATAM_HWs/HW4/basic_test.out";
    elf_res res = getFuncAddr(tst_prog_name, tst_func_name, &func_addr);
    

    //elf_res res = getFuncAddr(prog_name, func_name, &func_addr);
>>>>>>> d545d1771a474fbe039bcbc9d7b1c688d679bf48
    switch (res)
    {
    case ELF_OPEN_FAIL:
        printf("Elf open failed");
        exit(1);
    case ELF_NOT_EXECUTABLE:
        printf("PRF:: %s not an executable! :(\n", prog_name);
        exit(1);
    case ELF_NOT_FOUND:
        printf("PRF:: %s not found!\n", func_name);
        exit(1);
    case ELF_UND:
        printf("PRF:: %s is not a global symbol! :(\n", func_name);
        exit(1);
    }
    assert(res == ELF_SUCCESS);

    // for testing only
    func_addr = 400497;
    /////////////
    child_pid = run_target(tst_prog_name);
    run_revivo_debugger(child_pid, func_addr);

    return 0;
}