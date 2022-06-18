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
#define SHT_SYMTAB 0x2
#define SHT_STRTAB 0x3
#define STB_GLOBAL 1

typedef enum
{
    ELF_OPEN_FAIL,
    ELF_NOT_EXECUTABLE,
    ELF_NOT_FOUND,
    ELF_UND,
    ELF_SUCCESS,
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
        /* Allow tracing of this process */
        if (ptrace(PTRACE_TRACEME, 0, NULL, NULL) < 0)
        {
            perror("ptrace");
            exit(1);
        }
        /* Replace this process's image with the given program */
        execl(programname, programname, NULL);
    }
    else
    {
        // fork error
        perror("fork");
        exit(1);
    }
}

void run_breakpoint_debugger(pid_t child_pid)
{
    int wait_status;
    struct user_regs_struct regs;

    /* Wait for child to stop on its first instruction */
    wait(&wait_status);

    /* Look at the word at the address we're interested in */
    unsigned long addr = 0x4000cd;
    unsigned long data = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)addr, NULL);
    printf("DBG: Original data at 0x%x: 0x%x\n", addr, data);

    /* Write the trap instruction 'int 3' into the address */
    unsigned long data_trap = (data & 0xFFFFFFFFFFFFFF00) | 0xCC;
    ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data_trap);

    /* Let the child run to the breakpoint and wait for it to reach it */
    ptrace(PTRACE_CONT, child_pid, NULL, NULL);

    wait(&wait_status);
    /* See where the child is now */
    ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
    printf("DBG: Child stopped at RIP = 0x%x\n", regs.rip);

    /* Remove the breakpoint by restoring the previous data and set rdx = 5 */
    ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data);
    regs.rip -= 1;
    regs.rdx = 5;
    ptrace(PTRACE_SETREGS, child_pid, 0, &regs);

    /* The child can continue running now */
    ptrace(PTRACE_CONT, child_pid, 0, 0);

    wait(&wait_status);
    if (WIFEXITED(wait_status))
    {
        printf("DBG: Child exited\n");
    }
    else
    {
        printf("DBG: Unexpected signal\n");
    }
}

void run_syscall_debugger(pid_t child_pid)
{
    int wait_status;

    /* Wait for child to stop on its first instruction */
    wait(&wait_status);

    struct user_regs_struct regs;
    /* Enter next system call */
    ptrace(PTRACE_SYSCALL, child_pid, NULL, NULL);
    wait(&wait_status);

    ptrace(PTRACE_GETREGS, child_pid, NULL, &regs);
    regs.rdx = 5;
    ptrace(PTRACE_SETREGS, child_pid, NULL, &regs);

    /* Run system call and stop on exit */
    ptrace(PTRACE_SYSCALL, child_pid, NULL, NULL);
    wait(&wait_status);

    ptrace(PTRACE_GETREGS, child_pid, NULL, &regs);
    printf("DBG: the syscall returned: %d\n", regs.rax);

    /* The child can continue running now */
    ptrace(PTRACE_CONT, child_pid, 0, 0);
    wait(&wait_status);
    if (WIFEXITED(wait_status))
    {
        printf("DBG: Child exited\n");
    }
    else
    {
        printf("DBG: Unexpected signal\n");
    }
}

void run_regs_override_debugger(pid_t child_pid)
{
    int wait_status;

    /* Wait for child to stop on its first instruction */
    wait(&wait_status);
    while (WIFSTOPPED(wait_status))
    {
        struct user_regs_struct regs;

        ptrace(PTRACE_GETREGS, child_pid, NULL, &regs);
        regs.rdx = 5;
        ptrace(PTRACE_SETREGS, child_pid, NULL, &regs);

        /* Make the child execute another instruction */
        if (ptrace(PTRACE_SINGLESTEP, child_pid, NULL, NULL) < 0)
        {
            perror("ptrace");
            return;
        }

        /* Wait for child to stop on its next instruction */
        wait(&wait_status);
    }
}

void run_instruction_debugger(pid_t child_pid)
{
    int wait_status;
    int icounter = 0;

    /* Wait for child to stop on its first instruction */
    wait(&wait_status);
    while (WIFSTOPPED(wait_status))
    {
        icounter++;
        struct user_regs_struct regs;

        ptrace(PTRACE_GETREGS, child_pid, NULL, &regs);
        unsigned long instr = ptrace(PTRACE_PEEKTEXT, child_pid, regs.rip, NULL);

        printf("DBG: icounter = %u.  RIP = 0x%x.  instr = 0x%08x\n",
               icounter, regs.rip, instr);

        /* Make the child execute another instruction */
        if (ptrace(PTRACE_SINGLESTEP, child_pid, NULL, NULL) < 0)
        {
            perror("ptrace");
            return;
        }

        /* Wait for child to stop on its next instruction */
        wait(&wait_status);
    }
}

void run_counter_debugger(pid_t child_pid)
{
    int wait_status;
    int icounter = 0;

    /* Wait for child to stop on its first instruction */
    wait(&wait_status);
    while (WIFSTOPPED(wait_status))
    {
        icounter++;

        /* Make the child execute another instruction */
        if (ptrace(PTRACE_SINGLESTEP, child_pid, NULL, NULL) < 0)
        {
            perror("ptrace");
            return;
        }

        /* Wait for child to stop on its next instruction */
        wait(&wait_status);
    }

    printf("DBG: the child executed %d instructions\n", icounter);
}

void run_revivo_debugger(pid_t child_pid, long func_addr)
{
}

int isExecutable(int fd, Elf64_Ehdr *hdr)
{
    if (read(fd, hdr, sizeof(*hdr)) != sizeof(*hdr))
    {
        // Could not read elf header
        return 0;
    }
    if (memcmp("\x7fELF", hdr, MAGIC_LENGTH))
    {
        // Sanity check- Magic does not match
        return 0;
    }
    return hdr->e_type == ET_EXEC;
}

int funcExist(int fd, Elf64_Ehdr *hdr, Elf64_Shdr *symtab_hdr, Elf64_Shdr *strtab_hdr,
              Elf64_Sym *symbol_entry, char *func_name)
{
    Elf64_Shdr shdr_str_tbl, buf;
    int shdr_str_index, shdr_size, num_sections, num_symbols;
    char *section_names, *symbol_names;
    int i = 0, found_symtab = 0, found_strtab = 0;
    num_sections = hdr->e_shnum;

    // Go to section header table
    lseek(fd, hdr->e_shoff, SEEK_SET);

    // Get section header string table section header
    shdr_str_index = hdr->e_shstrndx;
    shdr_size = sizeof(Elf64_Shdr);
    lseek(fd, shdr_str_index * shdr_size, SEEK_CUR);
    if (read(fd, &shdr_str_tbl, sizeof(shdr_str_tbl)) != sizeof(shdr_str_tbl))
    {
        // Could not read section header
        return 0;
    }

    // Get section header string table as string
    lseek(fd, shdr_str_tbl.sh_offset, SEEK_SET);
    section_names = (char *)malloc(shdr_str_tbl.sh_size);
    if (read(fd, &section_names, sizeof(section_names)) != sizeof(section_names))
    {
        // Could not read section
        free(section_names);
        return 0;
    }

    // Get symtab and strtab headers
    lseek(fd, hdr->e_shoff, SEEK_SET);
    for (int i = 0; i < num_sections; i++)
    {
        if (read(fd, &buf, sizeof(buf)) != sizeof(buf))
        {
            // Could not read section header
            return 0;
        }
        if (!strcmp(section_names + buf.sh_name, ".symtab"))
        {
            found_symtab = 1;
            memcpy(symtab_hdr, &buf, sizeof(Elf64_Shdr));
        }
        if (!strcmp(section_names + buf.sh_name, ".strtab"))
        {
            found_strtab = 1;
            memcpy(strtab_hdr, &buf, sizeof(Elf64_Shdr));
        }
        if (found_symtab && found_strtab)
            break;
    }

    // Get strtab as string
    lseek(fd, strtab_hdr->sh_offset, SEEK_SET);
    symbol_names = (char *)malloc(strtab_hdr->sh_size);
    if (read(fd, &symbol_names, sizeof(symbol_names)) != sizeof(symbol_names))
    {
        // Could not read section
        free(section_names);
        free(symbol_names);
        return 0;
    }

    // Go to symbol table
    lseek(fd, symtab_hdr->sh_offset, SEEK_SET);

    // Look for func's symbol
    num_symbols = symtab_hdr->sh_size / symtab_hdr->sh_entsize;
    for (int i = 0; i < num_symbols; i++)
    {
        if (read(fd, symbol_entry, sizeof(*symbol_entry)) != sizeof(*symbol_entry))
        {
            // Could not read symbol entry
            return 0;
        }
        if (!strcmp(symbol_names + symbol_entry->st_name, func_name))
        {
            // The symbol exist
            free(section_names);
            free(symbol_names);
            return 1;
        }
    }
    // The symbol is not in the symtab
    free(section_names);
    free(symbol_names);
    return 0;
}

int isGlobal(int fd, Elf64_Sym *symbol_entry)
{
    return ELF64_ST_BIND(symbol_entry->st_info) == STB_GLOBAL;
}

elf_res getFuncAddr(char *prog_name, char *func_name, long *func_addr)
{
    Elf64_Ehdr hdr;
    Elf64_Shdr symtab_hdr;
    Elf64_Shdr strtab_hdr;
    Elf64_Sym symbol_entry;
    int fd = open(prog_name, O_RDONLY);
    if (fd == -1)
        return ELF_OPEN_FAIL;
    if (!isExecutable(fd, &hdr))
    {
        close(fd);
        return ELF_NOT_EXECUTABLE;
    }
    if (!funcExist(fd, &hdr, &symtab_hdr, &strtab_hdr, &symbol_entry, func_name))
    {
        close(fd);
        return ELF_NOT_FOUND;
    }
    if (!isGlobal(fd, &symbol_entry))
    {
        close(fd);
        return ELF_UND;
    }
    // FIND ADDRES
    *func_addr = 1;
    return ELF_SUCCESS;
}

int main(int argc, char **argv)
{
    pid_t child_pid;
    char *func_name, *prog_name;
    long func_addr;
    if (argc < MIN_ARG_C)
    {
        fprintf(stderr, "PRF:: Not enough args");
        exit(1);
    }
    func_name = argv[1];
    // 'run_target' is using 'execl' so by passing 'prog_name'
    // we are passing its args aswell (they are right after him
    // in the original 'argv' array).
    prog_name = argv[2];

    elf_res res = getFuncAddr(prog_name, func_name, &func_addr);
    switch (res)
    {
    case ELF_OPEN_FAIL:
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

    child_pid = run_target(prog_name);
    run_revivo_debugger(child_pid, func_addr);

    return 0;
}