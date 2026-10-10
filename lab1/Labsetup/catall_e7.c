#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/*
 * catall_e7.c — corrected version (E7, E8, E9)
 * P1: privilege dropped permanently BEFORE any external command runs
 * P2: no relative name / no shell — execve() only, no system()
 * P3: environment rebuilt from scratch (fixed PATH/IFS, nothing inherited)
 * P4: user input is always ONE filename argument, never a command
 */
int main(int argc, char *argv[])
{
    uid_t real = getuid();

    if (setresuid(real, real, real) != 0) {
        perror("setresuid");
        return 1;
    }

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    char *cmd[] = { "/bin/cat", "--", argv[1], NULL };
    char *env[] = { "PATH=/usr/bin:/bin", "IFS= \t\n", NULL };

    execve(cmd[0], cmd, env);
    perror("execve");
    return 1;
}
