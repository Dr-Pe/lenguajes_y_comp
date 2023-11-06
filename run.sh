#!/bin/bash

compilador="lyc-compiler-3.0.0.o"

# Script para Unix
flex lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c lista_simbolos.c arbol.c pila.c generar_assembler.c -o ${compilador}
./${compilador} "casos_de_prueba/testsimple.txt"
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm ${compilador}
