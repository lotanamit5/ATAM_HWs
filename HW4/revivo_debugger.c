#include "revivo_debugger.h"

void run_revivo_debugger(pid_t child_pid, Elf64_Addr addr, int is_dyn)
{
    int wait_status;
    struct user_regs_struct regs;
    unsigned long data, data_trap, next_instr, next_trap;
    Elf64_Addr got_entry, next_addr, stack_next_addr;
    int counter = 0;

    // Wait for child to stop on its first instruction
    waitpid(child_pid, &wait_status, 0);

    // If symbol is dynamic-
    // the addres is GOT entry addres and now contains addres of instruction in <symbol@plt>
    // we will place a breake point here
    if (is_dyn)
    {
        got_entry = addr;
        addr = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)got_entry, NULL);
    }

    // Write the trap instruction
    data = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)addr, NULL);
    data_trap = (data & 0xFFFFFFFFFFFFFF00) | 0xCC;
    ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data_trap);

    // Let the child run to the breakpoint and wait for it to reach it
    ptrace(PTRACE_CONT, child_pid, NULL, NULL);
    waitpid(child_pid, &wait_status, 0);

    while (!WIFEXITED(wait_status))
    {
        counter++;

        // Remove first breakpoint by restoring the previous data
        ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
        regs.rip -= 1;
        ptrace(PTRACE_SETREGS, child_pid, 0, &regs);
        ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data);

        // Get next instruction's addres and
        stack_next_addr = regs.rsp + 8;
        next_addr = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)regs.rsp, NULL);

        // Add break point at return addres
        next_instr = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)next_addr, NULL);
        next_trap = (next_instr & 0xFFFFFFFFFFFFFF00) | 0xCC;
        ptrace(PTRACE_POKETEXT, child_pid, (void *)next_addr, (void *)next_trap);

        // Let the child run to the next instruction
        ptrace(PTRACE_CONT, child_pid, NULL, NULL);
        waitpid(child_pid, &wait_status, 0);

        // Check if stack frames "folded back" to first call
        ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
        while (regs.rsp != stack_next_addr)
        {
            // If we got to this addres but the func hasn't finished-
            // Remove the second breakpoint by restoring the previous data
            regs.rip -= 1;
            ptrace(PTRACE_SETREGS, child_pid, 0, &regs);
            ptrace(PTRACE_POKETEXT, child_pid, (void *)next_addr, (void *)next_instr);
            
            // Let og instruction run
            ptrace(PTRACE_SINGLESTEP, child_pid, NULL, NULL);
			waitpid(child_pid, &wait_status, 0);
            
            // bring back second break point (after restoring data)
            ptrace(PTRACE_POKETEXT, child_pid, (void *)next_addr, (void *)next_trap);

            // Let the child run to the next instruction
            ptrace(PTRACE_CONT, child_pid, NULL, NULL);
            waitpid(child_pid, &wait_status, 0);

            // Check if stack frames "folded back" to first call
            ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
        }

        // Get return value
        int return_value;
        return_value = (0x80000000 & regs.rax) ? (-((~regs.rax) + 1)) : regs.rax;

        printf("PRF:: run #%d returned with %d\n", counter, return_value);

        // Remove the second breakpoint by restoring the previous data
        regs.rip -= 1;
        ptrace(PTRACE_SETREGS, child_pid, 0, &regs);
        ptrace(PTRACE_POKETEXT, child_pid, (void *)next_addr, (void *)next_instr);

        // Re-add the first breakpoint
        if (is_dyn && counter == 1)
        {
            // Now the data in the GOT entry is symbol's addres
            addr = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)got_entry, NULL);
            data = ptrace(PTRACE_PEEKTEXT, child_pid, (void *)addr, NULL);
            data_trap = (data & 0xFFFFFFFFFFFFFF00) | 0xCC;
        }
        ptrace(PTRACE_POKETEXT, child_pid, (void *)addr, (void *)data_trap);

        // Let the child run to the breakpoint and wait for it to reach it
        ptrace(PTRACE_CONT, child_pid, NULL, NULL);
        waitpid(child_pid, &wait_status, 0);
    }
}