LIBS=`pkg-config --cflags --libs glib-2.0`

filmes: y.tab.c lex.yy.c
	gcc -D_XOPEN_SOURCE=700 -std=c99 -o filmes y.tab.c $(LIBS)

y.tab.c y.tab.h: filmes.y
	yacc -dv filmes.y

lex.yy.c: filmes.l y.tab.h
	flex filmes.l

clean:
	rm filmes y.* lex.yy.c