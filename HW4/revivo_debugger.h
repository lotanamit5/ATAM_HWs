#ifndef _REVIVO_DEBUGGER_H
#define _REVIVO_DEBUGGER_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/reg.h>
#include <sys/user.h>
#include "elf_utils.h"

void run_revivo_debugger(pid_t child_pid, Elf64_Addr addr, int is_dyn);

#endif
