CC=gcc
CFLAGS=-c -g -Wfatal-errors

120++: main.o lex.yy.o token.o
	$(CC) -o 120++ main.o lex.yy.o token.o

main.o: main.c
	$(CC) $(CFLAGS) main.c

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) lex.yy.c
	
token.o: token.c token.h
	$(CC) $(CFLAGS) token.c

lex.yy.c: clex.l ytab.h
	flex clex.l
  
clean:
	\rm	*.o 120++ *.yy.c
















## phase 2: ignore for now

#c: main.o cgram.tab.o lex.yy.o
#	cc -o c main.o cgram.tab.o lex.yy.o

#cgram.tab.o: cgram.tab.c
#	cc -c -DYYDEBUG cgram.tab.c

#cgram.tab.c: cgram.y
#	bison -d -v cgram.y

#cgram.tab.h: cgram.tab.c
