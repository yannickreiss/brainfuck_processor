BIN		= bfc
CC		= gcc
LD		= ld
CFLAGS	= -Wall
LDFLAGS =
SRCDIR	= src/
INCLUDE	= include/
OBJECTS	= assembling.o analyzer.o tokenizer.o compiler.o
all: $(BIN)

$(BIN): $(OBJECTS)
	$(CC) -o $(BIN) $(OBJECTS) $(LDFLAGS)

%.o: $(SRCDIR)%.c
	$(CC) $(CFLAGS) -o $@ -c $<

run: $(BIN)
	./$(BIN)

clean:
	rm $(OBJECTS) $(BIN)

.PHONY: all clean run.
