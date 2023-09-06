#Archivo de compilación

flex lexico.l 
gcc lex.yy.c -lfl
./a.out prueba.txt