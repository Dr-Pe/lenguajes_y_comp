flex lexico.l
bison -dyv sintactico.y

gcc.exe lex.yy.c y.tab.c -o compilador.exe

compilador.exe casos_de_prueba/tipos_validos.txt

@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause