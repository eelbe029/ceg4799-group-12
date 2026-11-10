#include <stdio.h>
#include <stdlib.h>

int main(void) {
    char *shell = getenv("MYSH");
    if (shell != NULL) {
        printf("%p: %s\n", (void *)shell, shell);
    }
    return 0;
}


