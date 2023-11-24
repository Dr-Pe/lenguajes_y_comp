flex lexico.l
bison -dyv sintactico.y
gcc.exe lex.yy.c y.tab.c libc/utilidades.c libc/lista_simbolos.c libc/arbol.c libc/pila.c libc/generar_assembler.c -o lyc-compiler-2.5.0.o
lyc-compiler-2.5.0.o casos_de_prueba/test.txt
dot -Tpng intermediate-code.dot -o arbol.png -Gcharset=latin1

@echo off
del lyc-compiler-2.5.0.o
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause