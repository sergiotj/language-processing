all: tp1

tp1.c: tp1.l
	flex -o tp1.c tp1.l

tp1: tp1.c
	gcc -o tp1 tp1.c