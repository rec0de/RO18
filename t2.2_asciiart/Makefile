ASM=@gcc -m32
DBG_OPTIONS=-O0 -g
OBJECTS=io.o ascii_art.o
AFLAGS=

all: executable

debug: AFLAGS+= -O0 -g
debug: clean
debug: executable

.s.o:
	$(ASM) $(AFLAGS) -c $<

executable: $(OBJECTS)
	$(ASM) -o ascii_art $(OBJECTS)

clean:
	@rm -f *.o

