# CC=gcc
# CFLAGS=-m32 -Wall -g -c
# LDFLAGS =-m32 -z noexecstack

# all:	main.o f.o
# 		$(CC) $(LDFLAGS) main.o f.o -o fun

# main.o:	main.c
# 		$(CC) $(CFLAGS) main.c -o main.o

# f.o:	f.s
# 	nasm -f elf f.s

# clean:
# 		rm -f *.o





CC = gcc
ASM = nasm

CFLAGS = -Wall -g -c
LDFLAGS = -z noexecstack \
  -lallegro \
  -lallegro_main \
  -lallegro_image \
  -lallegro_font \
  -lallegro_ttf \
  -lallegro_primitives

TARGET = fun
OBJS = main.o f.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(TARGET)

main.o: main.c
	$(CC) $(CFLAGS) main.c -o main.o

f.o: f.s
	$(ASM) -f elf64 f.s -o f.o

clean:
	rm -f *.o $(TARGET)
