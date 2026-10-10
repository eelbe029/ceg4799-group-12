#include <stdio.h>
#include <stdlib.h>

/*
 * Vulnerable E6b fixture.  The command name is intentionally relative so
 * that PATH can select an attacker-controlled program.  This file is kept
 * separate from catall.c because the E6b script runs it as a dedicated
 * Set-UID fixture.
 */
int main(void)
{
    if (system("id") == -1) {
        perror("system");
        return 1;
    }
    return 0;
}
