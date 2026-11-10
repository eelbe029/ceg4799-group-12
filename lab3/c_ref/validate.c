#include <stdio.h>
#include <string.h>

#define MAX_LENGTH 64

/* VULNERABLE baseline: no length/content check before the copy. */
int validate(const char *input, char *buffer) {
    strcpy(buffer, input);   /* buffer is only MAX_LENGTH bytes -- overflow */
    return 1;                /* always "accepted" */
}

int main(int argc, char *argv[]) {
    if (argc < 2) { printf("usage: %s <input>\n", argv[0]); return 1; }
    char buffer[MAX_LENGTH];
    int status = validate(argv[1], buffer);
    printf("status=%d buffer=%s\n", status, buffer);
    return 0;
}
