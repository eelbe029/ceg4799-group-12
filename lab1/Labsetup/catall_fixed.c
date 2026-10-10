#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/*
 * Safe version of catall.c (E7, E8, E9)
 *
 * Properties this program guarantees:
 *  P1: Privilege is dropped permanently BEFORE any external command runs.
 *  P2: No command is run by relative name or through a shell (no system()).
 *  P3: The environment is rebuilt from scratch (PATH and IFS fixed, nothing inherited).
 *  P4: The user input is always ONE filename argument, never a command.
 */
int main(int argc, char *argv[])
{
    uid_t ruid, euid, suid;
    uid_t real = getuid();

    /* P1: drop privilege first, all three UIDs, not reversible */
    if (setresuid(real, real, real) != 0) {
        perror("setresuid");
        return 1;
    }

    /* Check: real, effective and saved UID must all equal the caller's UID */
    if (getresuid(&ruid, &euid, &suid) != 0 ||
        ruid != real || euid != real || suid != real) {
        fprintf(stderr, "privilege drop check failed\n");
        return 1;
    }

    /* Check: re-elevation to root must be impossible (skip if run by root) */
    if (real != 0 && setresuid(0, 0, 0) == 0) {
        fprintf(stderr, "re-elevation possible, aborting\n");
        return 1;
    }

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    /* P2 + P4: absolute path, "--" stops option parsing, filename is one argument */
    char *cmd[] = { "/bin/cat", "--", argv[1], NULL };

    /* P3: whitelist environment, nothing copied from the caller */
    char *env[] = { "PATH=/usr/bin:/bin", "IFS= \t\n", NULL };

    execve(cmd[0], cmd, env);

    /* only reached if execve failed */
    perror("execve");
    return 1;
}
