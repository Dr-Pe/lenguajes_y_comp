%{
    #include <stdio.h>
    #include <stdlib.h>
 
    #include "y.tab.h"
 
    int yystopparser=0;
    FILE* yyin;
    int yylval;
   
 
    int yyerror();
    int yylex();
%}
 
 
%token INT      
%token FLOAT      
%token STRING    
// Palabras reservadas
%token INIT      
%token DEC_INT    
%token DEC_FLOAT  
%token DEC_STRING
%token NOT      
%token IF      
%token ELSE    
%token CICLO
// Funciones builtin
%token WRITE    
%token READ
%token CONCAT
%token TIMER
%token ESTA_CONT
// ID
%token ID
// Caracteres especiales   
%token PA        
%token PC        
%token LLA      
%token LLC      
%token COMA      
%token DOS_P    
// Operadores aritmeticos
%token OP_AS
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
// Operadores logicos
%token AND
%token OR
%token MAYOR
%token MENOR
 
%%
programa_prima: programa;

programa: INIT LLA declaraciones LLC bloque_ejec;

declaraciones: dec | declaraciones dec;

dec: listado_ids DOS_P tipo;

listado_ids:
    ID
    |listado_ids COMA ID
    ;

tipo: DEC_INT | DEC_FLOAT | DEC_STRING;

bloque_ejec: sentencia | bloque_ejec sentencia;

sentencia:        
    asignacion
    |ciclo
    |eval
    |TIMER PA INT COMA bloque_ejec PC
    |WRITE PA ID PC
    |WRITE PA STRING PC
    |READ PA ID PC
    ;
 
asignacion:
    ID OP_AS expresion {printf("    ID = Expresion es ASIGNACION\n");}
    |ID OP_AS string 
    ;

string:
    STRING
    |CONCAT PA STRING COMA STRING COMA INT PC

ciclo: CICLO PA condicion PC LLA bloque_ejec LLC;

eval: 
    IF PA condicion PC LLA bloque_ejec LLC
    |IF PA condicion PC LLA bloque_ejec LLC ELSE LLA bloque_ejec LLC
    ;

condicion:
    comparacion
    |condicion op_logico comparacion
    |NOT condicion
    ;

comparacion:
    expresion comparador expresion
    |ESTA_CONT PA STRING COMA STRING PC
    ;

op_logico:
    AND
    |OR
    ;

comparador:
    MAYOR
    |MENOR
    ;

expresion:
    termino {printf("    Termino es Expresion\n");}
    |expresion OP_SUM termino {printf("    Expresion+Termino es Expresion\n");}
    |expresion OP_RES termino {printf("    Expresion-Termino es Expresion\n");}
    ;
 
termino:
    factor {printf("    Factor es Termino\n");}
    |termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
    |termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
    ;
 
factor:
    ID {printf("    ID es Factor \n");}
    | INT {printf("INT es Factor\n");}
    | FLOAT {printf("FLOAT es Factor\n");}
    | PA expresion PC {printf("    Expresion entre parentesis es Factor\n");}
    ;
 
 
%%
 
int main(int argc, char *argv[]) {
    if((yyin = fopen(argv[1], "rt"))==NULL) {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else {
        yyparse();
    }
    fclose(yyin);
    return 0;
}
 
int yyerror() {
    printf("Error\n");
    exit (1);
}