#!/bin/bash

compilador="lyc-compiler-2.5.0.o"
libc="libc/utilidades.c libc/lista_simbolos.c libc/arbol.c libc/pila.c libc/generar_assembler.c"

# Script para Unix
flex lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c ${libc} -o ${compilador}
./${compilador} "casos_de_prueba/test_simple.txt"
dot -Tpng intermedia.dot -o arbol.png -Gcharset=latin1
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm ${compilador}
