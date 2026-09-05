#ifndef LUMEN_COMPOSITOR_H
#define LUMEN_COMPOSITOR_H

#include <stdbool.h>

struct lumen_compositor {
    bool running;
};

bool lumen_compositor_init(struct lumen_compositor *compositor);
void lumen_compositor_shutdown(struct lumen_compositor *compositor);

#endif
