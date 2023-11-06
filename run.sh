#!/bin/bash

# Script para Unix
flex lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c lista_simbolos.c arbol.c pila.c generar_assembler.c -o lyc-compiler-2.0.0.o
./lyc-compiler-2.0.0.o "casos_de_prueba/testsimple.txt"
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm lyc-compiler-2.0.0
