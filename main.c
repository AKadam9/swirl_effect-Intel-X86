#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#include <GL/glut.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void flip_vertical(unsigned char *data, int width, int height, int pitch) {
    unsigned char *row_buffer = malloc(pitch);
    if (!row_buffer) return;

    for (int i = 0; i < height / 2; i++) {
        unsigned char *top = data + i * pitch;
        unsigned char *bottom = data + (height - 1 - i) * pitch;

        memcpy(row_buffer, top, pitch);
        memcpy(top, bottom, pitch);
        memcpy(bottom, row_buffer, pitch);
    }
    free(row_buffer);
}

void swirl_effect(unsigned char *src_data, unsigned char *dst_data, int width, int height, int pitch, double const_k);

// Globals
unsigned char *originalBitmap = NULL;
unsigned char *swirledBitmap = NULL;
int width, height, channels;
double current_k = 0.0;

void display() {
    // Apply swirl with current K
    swirl_effect(originalBitmap, swirledBitmap, width, height, width * 4, current_k);

    flip_vertical(swirledBitmap, width, height, width * 4);

    glClear(GL_COLOR_BUFFER_BIT);
    glRasterPos2i(-1, -1);
    glDrawPixels(width, height, GL_RGBA, GL_UNSIGNED_BYTE, swirledBitmap);
    glutSwapBuffers();
}

void prompt_for_k(int value) {
    printf("Enter swirl constant K (float, Ctrl+C to quit): ");
    fflush(stdout);

    if (scanf("%lf", &current_k) == 1) {
        printf("Applying swirl with K = %f\n", current_k);
        glutPostRedisplay(); // trigger a redraw
    } else {
        printf("Invalid input or EOF. Exiting...\n");
        exit(0);
    }

    glutTimerFunc(100, prompt_for_k, 0); // repeat
}

void cleanup() {
    if (originalBitmap) stbi_image_free(originalBitmap);
    if (swirledBitmap) free(swirledBitmap);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <image.png>\n", argv[0]);
        return 1;
    }

    originalBitmap = stbi_load(argv[1], &width, &height, &channels, 4);
    if (!originalBitmap) {
        fprintf(stderr, "Failed to load image.\n");
        return 1;
    }

    swirledBitmap = malloc(height * width * 4);
    if (!swirledBitmap) {
        fprintf(stderr, "Memory allocation failed.\n");
        stbi_image_free(originalBitmap);
        return 1;
    }

    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA);
    glutInitWindowSize(width, height);
    glutCreateWindow("Swirl Effect");

    glutDisplayFunc(display);
    atexit(cleanup);

    // Prompt for K repeatedly every 100ms
    glutTimerFunc(100, prompt_for_k, 0);

    glutMainLoop();

    return 0;
}
