# Compiler and flags
CC := $(CROSS_COMPILE)gcc
CFLAGS := -Wall -Wextra

# Source and object files
SRC := writer.c
OBJ := $(SRC:.c=.o)

# Default target to build the "writer" application
writer: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

# Clean target to remove the application and object files
clean:
	rm -f writer $(OBJ)

