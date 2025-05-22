#include <stdlib.h>
#include <stdint.h>

// Prototype of your ASM function
extern void swirl_effect(uint8_t *src, uint8_t *dst, int width, int height, int pitch);

int main() {
    int width = 2000, height = 1000, pitch = width * 4;
    // Allocate exactly the buffer your ASM expects
    uint8_t *src = malloc(pitch * height);
    uint8_t *dst = malloc(pitch * height);
    if (!src || !dst) return 1;
    // Fill src with some data
    for (int i = 0; i < pitch * height; i++) src[i] = (uint8_t)(i & 0xFF);

    // Call your assembly swirl routine
    swirl_effect(src, dst, width, height, pitch);

    free(src);
    free(dst);
    return 0;
}
