#!/bin/bash

## Script para Unix
flex lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c tab_simb.c -o compilador
./compilador "$1"
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compilador
