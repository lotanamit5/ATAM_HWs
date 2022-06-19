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

int isExecutable(int fd)
{
    Elf64_Ehdr hdr;
    if (read(fd, &hdr, sizeof(hdr)) != sizeof(hdr))
    {
        // Could not read elf header
        return 0;
    }
    if (memcmp("\x7fELF", &hdr, MAGIC_LENGTH))
    {
        // Sanity check- Magic does not match
        return 0;
    }
    return hdr.e_type == ET_EXEC;
}

int funcExist(int fd, char *func_name)
{
    return 0;
}

int isGlobal(int fd, char *func_name)
{
    return 0;
}

elf_res getFuncAddr(char *prog_name, char *func_name, long *func_addr)
{
    Elf64_Sym prog_sym;
    int fd = open(prog_name, O_RDONLY);
    if (fd == -1)
        return ELF_OPEN_FAIL;
    if (!isExecutable(fd))
    {
        close(fd);
        return ELF_NOT_EXECUTABLE;
    }
    if (!funcExist(fd, func_name))
    {
        close(fd);
        return ELF_NOT_FOUND;
    }
    if (!isGlobal(fd, func_name))
    {
        close(fd);
        return ELF_UND;
    }
    // FIND ADDRESS:
    if (prog_sym.st_shndx != SHN_UNDEF)
        *func_addr = prog_sym.st_value;
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