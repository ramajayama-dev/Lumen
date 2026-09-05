#include "lumen/compositor.h"

#include <stdio.h>

int main(void)
{
    struct lumen_compositor compositor = {0};

    printf("Lumen compositor starting...\n");

    if (!lumen_compositor_init(&compositor)) {
        fprintf(stderr, "Failed to initialize Lumen compositor.\n");
        return 1;
    }

    printf("Lumen compositor is running.\n");

    lumen_compositor_shutdown(&compositor);

    printf("Lumen compositor exited cleanly.\n");

    return 0;
}
