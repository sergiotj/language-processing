all: tp1

tp1Gen.c: tp1.l
	flex -o tp1Gen.c tp1.l

tp1: tp1Gen.c
	gcc -o tp1 tp1Gen.c