#include <stdio.h>

#include <stdio.h>
#include <stdlib.h>

#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>

#include "f.h"


int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("Argument missing \n.");
        return -1;
    }


     // Initialize Allegro
    if (!al_init()) {
        fprintf(stderr, "Failed to initialize Allegro!\n");
        return -1;
    }

    if (!al_init_image_addon()) {
        fprintf(stderr, "Failed to initialize image addon!\n");
        return -1;
    }

    // Load image
    ALLEGRO_BITMAP *input = al_load_bitmap("panda.png");
    if (!input) {
        fprintf(stderr, "Failed to load image!\n");
        return -1;
    }

    int width = al_get_bitmap_width(input);
    int height = al_get_bitmap_height(input);


    ALLEGRO_DISPLAY *display = al_create_display(width, height);
    if (!display) {
        fprintf(stderr, "Failed to create display!\n");
        return -1;
    }

    // Create output image
    // ALLEGRO_BITMAP *output = al_create_bitmap(width, height);
    ALLEGRO_BITMAP *output = al_clone_bitmap(input);
    if (!output) {
        fprintf(stderr, "Failed to create output bitmap!\n");
        return -1;
    }

    int format = al_get_bitmap_format(input);
    printf("Bitmap format: %d\n", format);

    int width_out = al_get_bitmap_width(output);
    int height_out = al_get_bitmap_height(output);

    // Lock bitmaps for pixel access
    ALLEGRO_LOCKED_REGION *src_lock = al_lock_bitmap(input, ALLEGRO_PIXEL_FORMAT_ARGB_8888, ALLEGRO_LOCK_READWRITE);
    ALLEGRO_LOCKED_REGION *dst_lock = al_lock_bitmap(output, ALLEGRO_PIXEL_FORMAT_ARGB_8888, ALLEGRO_LOCK_READWRITE);


    if (!src_lock || !dst_lock) {
        fprintf(stderr, "Failed to lock bitmaps!\n");
        return -1;
    }

    printf("Pitch: %d, width: %d, height: %d\n", src_lock->pitch, width, height);

    int pitch = src_lock->pitch;
    if (pitch < 0)
        pitch = -pitch;

    printf("Pitch: %d, width: %d, height: %d\n", pitch, width_out, height_out);

    // int x = width * 4;
    // Call assembly swirl function
    swirl_effect(
        (unsigned char*)src_lock->data,
        (unsigned char*)dst_lock->data,
        width, height,
        pitch // bytes per row
    );

    // Unlock bitmaps
    al_unlock_bitmap(input);
    al_unlock_bitmap(output);

    // Draw result
    // al_clear_to_color(al_map_rgb(0, 0, 0));
    al_draw_bitmap(output, 0, 0, 0);
    al_flip_display();

    // Wait for key press
    al_rest(5.0);

    // Cleanup
    al_destroy_bitmap(input);
    al_destroy_bitmap(output);
    al_destroy_display(display);

    return 0;
}