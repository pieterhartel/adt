OBJECTS = grammar.o lex.o generated.o primitive.o
SRCS    = grammar.y lex.l generated.c primitive.c
CFLAGS=	-Wall -pedantic -Wswitch -g -Wmissing-declarations -O
LEX=flex
YFLAGS=-d

CC=gcc

all: test

test: adt.exe
	./adt.exe -h -c -cd -ct -cf adt.adt
	-sed 's/generated/adt/' < generated.c | diff adt.c -
	-sed 's/generated/adt/' < generated.h | diff adt.h -

install: adt.exe
	cp adt.exe $(HOME)/bin/
	/bin/rm -f generated.c.bak generated.h.bak
	mv generated.c generated.c.bak
	mv generated.h generated.h.bak
	sed -e 's/adt\.h/generated.h/' < adt.c > generated.c
	sed -e 's/_adt_/_generated_/' < adt.h > generated.h

adt.exe : $(OBJECTS)
	$(CC) $(CFLAGS) -o adt.exe $(OBJECTS) -ll

zip : ALWAYS
	zip adt.zip README LICENCE Makefile adt.[ch] tree.adt adt.adt flags.h generated.[ch] grammar.y lex.l primitive.[ch]

clean:	ALWAYS
	/bin/rm -f $(OBJECTS) adt.o

spotless: clean
	/bin/rm -f adt.exe

depend:
	makedepend -Y $(SRCS) 2> /dev/null

ALWAYS:
# DO NOT DELETE

grammar.o: primitive.h flags.h generated.h
lex.o: primitive.h generated.h y.tab.h
generated.o: primitive.h generated.h
primitive.o: primitive.h
