#!/bin/bash

## Script para Unix
flex lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c tab_simb.c arbol.c pila.c -o lyc-compiler-1_0_0.exe
./lyc-compiler-1_0_0.exe "casos_de_prueba/test.txt"
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm lyc-compiler-1_0_0.exe
