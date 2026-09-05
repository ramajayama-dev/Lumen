#include "lumen/compositor.h"

#include <stdio.h>

bool lumen_compositor_init(struct lumen_compositor *compositor)
{
    if (compositor == NULL) {
        return false;
    }

    compositor->running = true;

    printf("Lumen compositor core initialized.\n");

    return true;
}

void lumen_compositor_shutdown(struct lumen_compositor *compositor)
{
    if (compositor == NULL) {
        return;
    }

    compositor->running = false;

    printf("Lumen compositor core shut down.\n");
}
