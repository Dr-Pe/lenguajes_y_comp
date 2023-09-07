<<<<<<< HEAD
#!bin/bash

## Script para Unix
flex lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c -o compilador
./compilador prueba.txt
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compilador
=======
#Archivo de compilación

flex lexico.l 
gcc lex.yy.c -lfl
./a.out prueba.txt
>>>>>>> 21765a11a980d416fe827eaf9aec107feb6c5ff3
