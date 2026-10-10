#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>

int main(void)
{
    uid_t ruid, euid, suid;

    getresuid(&ruid, &euid, &suid);
    printf("Avant: ruid=%d euid=%d suid=%d\n", ruid, euid, suid);

    if (setresuid(getuid(), getuid(), getuid()) != 0) {
        perror("setresuid");
        return 1;
    }

    getresuid(&ruid, &euid, &suid);
    printf("Après: ruid=%d euid=%d suid=%d\n", ruid, euid, suid);

    if (setresuid(-1, 0, -1) != 0)
        perror("Tentative de récupération de root");
    else
        printf("Récupération de root réussie\n");

    return 0;
}
