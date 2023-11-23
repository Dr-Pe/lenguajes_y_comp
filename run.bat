set compilador="lyc-compiler-2.5.0.o"
set libc="libc/utilidades.c libc/lista_simbolos.c libc/arbol.c libc/pila.c libc/generar_assembler.c"

flex lexico.l
bison -dyv sintactico.y
gcc.exe lex.yy.c y.tab.c %libc% -o %compilador%
./%compilador% casos_de_prueba/test.txt
dot -Tpng intermedia-code.dot -o arbol.png -Gcharset=latin1

@echo off
del %compilador%
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause