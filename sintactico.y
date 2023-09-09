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
%token WRITE    
%token READ
%token IF      
%token ELSE    
%token CICLO    
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
sentencia:        
    asignacion {printf(" FIN\n");} ;
 
asignacion:
    ID OP_AS expresion {printf("    ID = Expresion es ASIGNACION\n");}
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