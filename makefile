CC = gcc
ASM = nasm

CFLAGS = -Wall -g -c
LDFLAGS = -no-pie -z noexecstack \
  -lallegro \
  -lallegro_main \
  -lallegro_image \
  -lallegro_font \
  -lallegro_ttf \
  -lallegro_primitives

TARGET = test_swirl
OBJS = main.o f.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(TARGET)

main.o: main.c
	$(CC) $(CFLAGS) main.c -o main.o

f.o: f.s
	$(ASM) -f elf64 -g -F dwarf f.s -o f.o

clean:
	rm -f *.o $(TARGET)
