%{
    #include "tab_simb.h"
    #include "y.tab.h"
 
    int yystopparser=0;
    FILE* yyin;
    // int yylval;

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
// Comparadores
%token MAYOR
%token MENOR
%token IGUAL
%token DISTINTO
%token MAYOR_IGUAL
%token MENOR_IGUAL
 
%%
programa_prima: programa    {printf("COMPILADO\n");}
    ;
programa: INIT LLA declaraciones LLC bloque_ejec    {printf("init {declaraciones} bloque_ejec es Programa\n");} 
    | INIT LLA LLC bloque_ejec                      {printf("init {} bloque_ejec es Programa\n");}
    ;

declaraciones: dec          {printf("dec es Declaraciones\n");}
    | declaraciones dec     {printf("declaraciones dec es Declaraciones\n");}
    ;

dec: listado_ids DOS_P tipo {printf("listado_ids : tipo es Dec\n");}
    ;

listado_ids:
    ID                      {printf("id es Listado_ids\n");}
    |listado_ids COMA ID    {printf("listado_ids , id es Listado_ids\n");}
    ;

tipo: DEC_INT       {printf("dec_int es Tipo\n");}
    | DEC_FLOAT     {printf("dec_float es Tipo\n");}
    | DEC_STRING    {printf("dec_string es Tipo\n");}
    ;

bloque_ejec: sentencia                  {printf("sentencia es Bloque_ejec\n");}
    | bloque_ejec sentencia            {printf("bloque_ejec sentencia es Bloque_ejec\n");}
    ;
sentencia:        
    asignacion                          {printf("asignacion es Sentencia\n");}
    |ciclo                              {printf("ciclo es Sentencia\n");}
    |eval                               {printf("eval es Sentencia\n");}
    |TIMER PA INT COMA bloque_ejec PC   {printf("timer(int,bloque_ejec) es Sentencia\n");}
    |WRITE PA ID PC                     {printf("write(id) es Sentencia\n");}
    |WRITE PA STRING PC                 {printf("write(string) es Sentencia\n");}
    |READ PA ID PC                      {printf("read(id) es Sentencia\n");}
    ;
 
asignacion:
    ID OP_AS expresion {printf("ID = Expresion es ASIGNACION\n");}
    |ID OP_AS string    {printf("ID = String es ASIGNACION\n");}
    ;

string:
    STRING
    |CONCAT PA STRING COMA STRING COMA INT PC   {printf("ConcatenarConRecorte(String, String, Int) es String\n");}
    ;
ciclo: CICLO PA condicion PC LLA bloque_ejec LLC    {printf("ciclo(Condicion) {bloque_ejec} es Ciclo\n");}
    ;
eval: 
    IF PA condicion PC LLA bloque_ejec LLC                              {printf("if (condicion) {bloque_ejec} es Eval\n");}
    |IF PA condicion PC LLA bloque_ejec LLC ELSE LLA bloque_ejec LLC    {printf("if (condicion) {bloque_ejec} else {bloque_ejec} es Eval\n");}
    ;

condicion:
    comparacion                             {printf("comparacion es Condicion\n");}
    //|condicion op_logico comparacion        {printf("condicion op_logico comparacion es Condicion\n");}
    |condicion op_logico condicion        {printf("condicion op_logico comparacion es Condicion\n");}
    ;

comparacion:
    expresion comparador expresion          {printf("expresion comparador expresion es Comparacion\n");}
    |ESTA_CONT PA STRING COMA STRING PC     {printf("EstaContenido(String, String) es Comparacion\n");}
    |NOT comparacion                        {printf("not comparacion es Comparacion\n");}
    ;

op_logico:
    AND             {printf("& es Op_logico\n");}
    |OR             {printf("|| es Op_logico\n");}
    ;

comparador:
    MAYOR           {printf("> es Comparador\n");}
    |MENOR          {printf("< es Comparador\n");}
    |IGUAL          {printf("== es Comparador\n");}
    |DISTINTO       {printf("!= es Comparador\n");}
    |MAYOR_IGUAL    {printf(">= es Comparador\n");}
    |MENOR_IGUAL    {printf("<= es Comparador\n");}
    ;

expresion:
    termino {printf("Termino es Expresion\n");}
    |expresion OP_SUM termino {printf("Expresion+Termino es Expresion\n");}
    |expresion OP_RES termino {printf("Expresion-Termino es Expresion\n");}
    ;
 
termino:
    factor {printf("Factor es Termino\n");}
    |OP_RES factor  {printf("-Factor es Termino\n");}
    |termino OP_MUL factor {printf("Termino*Factor es Termino\n");}
    |termino OP_DIV factor {printf("Termino/Factor es Termino\n");}
    ;
 
factor:
    ID {printf("ID es Factor \n");}
    | INT {printf("INT es Factor\n");}
    | FLOAT {printf("FLOAT es Factor\n");}
    | PA expresion PC {printf("Expresion entre parentesis es Factor\n");}
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
    imprimirLista(&lista);
    return 0;
}
 
int yyerror() {
    printf("Error sintáctico\n");
    exit (1);
}