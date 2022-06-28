#ifndef _ELF_UTILS_H
#define _ELF_UTILS_H

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

typedef enum
{
    ELF_FAIL,
    ELF_NOT_EXECUTABLE,
    ELF_NOT_FOUND,
    ELF_UND,
    ELF_STATIC,
    ELF_DYNAMIC,
} elf_res;

elf_res getFuncAddr(char *prog_name, char *func_name, Elf64_Addr *func_addr);

#endif
