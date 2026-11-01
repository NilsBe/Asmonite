/* sample.c - C syntax highlighting test
   (multi-line block comment) */

#include <stdio.h>
#include "local.h"
#define BUFFER_SIZE 0x100

typedef struct {
    const char *name;
    unsigned int count;
} Entry;

static int sum(const int *values, size_t n)
{
    int total = 0;
    for (size_t i = 0; i < n; ++i)
        total += values[i];   // accumulate
    return total;
}

int main(void)
{
    int data[] = { 1, 2, 3, 42 };
    double ratio = 1.5e-3;
    char quote = '\'';

    printf("Sum = %d\n", sum(data, sizeof data / sizeof data[0]));
    printf("ratio = %f, quote = %c, tab = \"\t\"\n", ratio, quote);
    return 0;
}
