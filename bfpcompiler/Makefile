BIN		= FUUUUUCK
CC		= gcc
LD		= ld
CFLAGS	= -Wall
LDFLAGS =
SRCDIR	= src/
INCLUDE	= include/
OBJECTS	= compilefuck.o

all: $(BIN)

$(BIN): $(OBJECTS)
	$(CC) -o $(BIN) $(OBJECTS) $(LDFLAGS)

%.o: $(SRCDIR)%.c
	$(CC) $(CFLAGS) -o $@ $<

run: $(BIN)
	./$(BIN)

clean:
	rm $(OBJECTS) $(BIN)

.PHONY: all clean run.
