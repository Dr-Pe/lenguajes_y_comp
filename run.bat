flex lexico.l
bison -dyv sintactico.y

gcc.exe lex.yy.c y.tab.c tab_simb.c arbol.c pila.c -o lyc-compiler-2.0.0.o
lyc-compiler-2.0.0.o casos_de_prueba/test.txt

@echo off
del lyc-compiler-2.0.0.o
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause