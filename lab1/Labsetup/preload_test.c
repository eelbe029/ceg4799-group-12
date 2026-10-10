#include <stdio.h>

__attribute__((constructor))
void init(void)
{
    fprintf(stderr, "LD_PRELOAD_ACTIF\n");
}
