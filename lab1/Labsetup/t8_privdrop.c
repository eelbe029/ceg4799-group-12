#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>

/* T8: show that setresuid() drops privilege permanently (E8) */
static void show(const char *label)
{
    uid_t r, e, s;
    getresuid(&r, &e, &s);
    printf("%-14s real=%u effective=%u saved=%u\n", label, r, e, s);
}

int main(void)
{
    uid_t real = getuid();

    show("Before drop:");
    printf("Read /etc/shadow (needs root): %s\n",
           fopen("/etc/shadow", "r") ? "OK" : "DENIED");

    if (setresuid(real, real, real) != 0) { perror("setresuid"); return 1; }
    show("After drop:");

    if (setresuid(0, 0, 0) == 0) {
        printf("FAIL: re-elevation succeeded\n");
        return 1;
    }
    perror("Re-elevation to root");
    printf("Read /etc/shadow (needs root): %s\n",
           fopen("/etc/shadow", "r") ? "OK" : "DENIED");
    show("Final:");
    return 0;
}
