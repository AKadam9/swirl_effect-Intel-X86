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




# Compiler and Assembler
CC = gcc
ASM = nasm

# Compiler and assembler flags
CFLAGS = -Wall -g -c
ASMFLAGS = -f elf64 -g -F dwarf      # Add debug info for gdb debugging

# Linker flags for OpenGL, GLUT, and math
LDFLAGS = -lGL -lGLU -lglut -lm

# Target binary
TARGET = fun

# Object files
OBJS = main.o f.o

# Default target
all: $(TARGET)

# Link the final executable
$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(TARGET)

# Compile main.c
main.o: main.c
	$(CC) $(CFLAGS) -o main.o main.c

# Assemble f.s (assembly file)
f.o: f.s
	$(ASM) $(ASMFLAGS) -o f.o f.s

# Clean build artifacts
clean:
	rm -f *.o $(TARGET)
