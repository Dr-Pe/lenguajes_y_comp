%{
    #include "tab_simb.h"
    #include "y.tab.h"
    #include "arbol.h"
    int yystopparser=0;
    FILE* yyin;

    int yyerror();
    int yylex();

    Arbol compilado;
    //int yylval;

    NodoA* CompiladoPtr, *ProgramaPtr, *DeclaPtr, *BloPtr, *DecPtr, *ListPtr, *SentPtr, *AsigPtr, 
            *CicPtr, *EvalPtr, *Eptr, *StrPtr, *ConPtr, *CmpPtr, *EptrAux, *BloAux, *Tptr, *Fptr, *CmpAux, *StrPtrAux;
    NodoA* EjePtr, * ConAux;
    
    char  auxTipo[10], strAux[10], strAux2[10], cmpAux[10], opAux[10];

    char* concatenar(char*, char*, int);
    int estaContenido(char*, char*);
    Lista listaIds;
   
%}

 
%token <int_val>INT    
%token <float_val>FLOAT      
%token <string_val>STRING    
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
%token <string_val>ID
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

%union {
    int int_val;
    float float_val;
    char string_val[50];
} 
 
%%
programa_prima: 
    programa    {printf("R1: COMPILADO\n"); compilado = ProgramaPtr;}
    ;
programa: 
    INIT LLA declaraciones LLC bloque_ejec    {printf("\tR2: init {declaraciones} bloque_ejec es Programa\n"); ProgramaPtr = crearNodo("Programa", DeclaPtr, BloPtr);} 
    | INIT LLA LLC bloque_ejec                      {printf("\tR3: init {} bloque_ejec es Programa\n"); ProgramaPtr = BloPtr;}
    ;

declaraciones: 
    dec          {printf("\tR4: dec es Declaraciones\n"); DeclaPtr = DecPtr;}
    | declaraciones dec     {printf("\tR5: declaraciones dec es Declaraciones\n"); DeclaPtr = crearNodo("Mdeclaraciones", DeclaPtr, DecPtr);}
    ;

dec: 
    listado_ids DOS_P tipo {printf("\t\tR6: listado_ids : tipo es Dec\n"); asignarTipo(&listaIds, auxTipo);DecPtr = crearNodo(":", ListPtr, crearHoja(auxTipo));}
    ;

listado_ids:
    ID                      {printf("\t\tR7: id es Listado_ids\n");vaciarLista(&listaIds); insertarEnLista(&listaIds, $1, tID);ListPtr = crearHoja($1);}
    |listado_ids COMA ID    {printf("\t\tR8: listado_ids , id es Listado_ids\n"); insertarEnLista(&listaIds, $3, tID); ListPtr = crearNodo(",", ListPtr, crearHoja($3));}
    ;

tipo: 
    DEC_INT       {printf("\t\tR9: dec_int es Tipo\n"); strcpy(auxTipo, "int"); }
    | DEC_FLOAT     {printf("\t\tR10: dec_float es Tipo\n"); strcpy(auxTipo, "float");}
    | DEC_STRING    {printf("\t\tR11: dec_string es Tipo\n"); strcpy(auxTipo, "string");}
    ;

bloque_ejec: 
    sentencia                          {printf("\tR12: sentencia es Bloque_ejec\n"); BloPtr = SentPtr;}
    | bloque_ejec{BloAux = BloPtr;} sentencia            {printf("\tR13: bloque_ejec sentencia es Bloque_ejec\n"); BloPtr = crearNodo("BloEjec", BloAux, SentPtr);}
    ;



sentencia:        
    asignacion                          {printf("\t\tR14: asignacion es Sentencia\n"); SentPtr = AsigPtr;}
    |ciclo                              {printf("\t\tR15: ciclo es Sentencia\n"); SentPtr = CicPtr;}
    |eval                               {printf("\t\tR16: eval es Sentencia\n"); SentPtr = EvalPtr;}
    |TIMER PA INT COMA bloque_ejec PC   {printf("\t\tR17: timer(int,bloque_ejec) es Sentencia\n"); SentPtr = crearNodo("Ciclo", crearNodo("<", crearHoja("0"), crearHoja(itoa(yylval.int_val, strAux , 10))), BloPtr);}
    |WRITE PA ID PC                     {printf("\t\tR18: write(id) es Sentencia\n"); SentPtr = crearNodo("Write", crearHoja($3), crearHoja("DirMem"));}
    |WRITE PA STRING PC                 {printf("\t\tR19: write(string) es Sentencia\n"); SentPtr = crearNodo("Write", crearHoja($3), crearHoja("DirMem"));}
    |READ PA ID PC                      {printf("\t\tR20: read(id) es Sentencia\n"); SentPtr = crearNodo(":=", crearHoja($3), crearHoja("READ"));}
    ;
 
asignacion:
    ID OP_AS expresion {printf("\t\tR21: ID = Expresion es ASIGNACION\n"); AsigPtr = crearNodo(":=", crearHoja($1), Eptr);}
    |ID OP_AS string   {printf("\t\tR22: ID = String es ASIGNACION\n"); AsigPtr = crearNodo(":=", crearHoja($1), StrPtr);}
    ;

string:
    STRING                                      {printf("\t\t\tR23: string es String\n"); StrPtr = crearHoja($1);}
    |CONCAT PA STRING { strcpy(strAux, $3);} COMA STRING { strcpy(strAux2, $6);} COMA INT PC   {printf("\t\t\tR24: concatenarConRecorte(String, String, Int) es String\n"); StrPtr = crearHoja(concatenar(strAux, strAux2, yylval.int_val));}
    ;   //TODO: revisar concat $6 o $5?


ciclo: 
    CICLO PA condicion PC LLA bloque_ejec LLC    {printf("\t\tR25: ciclo(Condicion) {bloque_ejec} es Ciclo\n"); CicPtr = crearNodo("Ciclo", ConPtr, BloPtr);}
    ;

eval: 
    IF PA condicion PC LLA bloque_ejec LLC                              {printf("\t\tR26: if (condicion) {bloque_ejec} es Eval\n"); EvalPtr = crearNodo("IF", ConPtr, BloPtr);}
    |IF PA condicion PC LLA bloque_ejec LLC { BloAux = BloPtr ;} ELSE LLA bloque_ejec LLC    { printf("\t\tR27: if (condicion) {bloque_ejec} else {bloque_ejec} es Eval\n"); EvalPtr = crearNodo("IF", ConPtr, crearNodo("Cuerpo", BloAux, BloPtr));}
    ;


condicion:
    comparacion                             {printf("\t\t\tR28: comparacion es Condicion\n"); ConPtr = CmpPtr;}
   // |comparacion {strcpy(cmpAux, CmpPtr->simbolo);} op_logico comparacion      {printf("\t\t\tcomparacion op_logico comparacion es Condicion\n"); ConPtr = crearNodo(opAux, crearHoja(cmpAux), CmpPtr);}
    |comparacion {CmpAux = CmpPtr;} op_logico comparacion      {printf("\t\t\tR29: comparacion op_logico comparacion es Condicion\n"); ConPtr = crearNodo(opAux, CmpAux, CmpPtr);}
    ;

comparacion:
    expresion {EptrAux = Eptr;} comparador expresion          {printf("\t\t\t\tR30: expresion comparador expresion es Comparacion \n"); CmpPtr = crearNodo(cmpAux, EptrAux, Eptr);}
    |ESTA_CONT PA STRING {strcpy(strAux, $3);} COMA STRING PC     {printf("\t\t\t\tR31: estaContenido(String, String) es Comparacion\n"); CmpPtr = crearHoja(estaContenido(strAux, yylval.string_val)? "true" : "false" );}
    |NOT comparacion                        {printf("\t\t\t\tR32: not comparacion es Comparacion\n"); CmpPtr = crearNodo("&", crearHoja("false"), CmpPtr);}
    |NOT expresion                          {printf("\t\t\t\tR33: not expresion es Comparacion\n"); CmpPtr = crearNodo("&", crearHoja("false"), Eptr);}
    ;

op_logico:
    AND             {printf("\t\t\t\tR34: & es Op_logico\n"); strcpy(opAux,"&");}
    |OR             {printf("\t\t\t\tR35: || es Op_logico\n"); strcpy(opAux,"||");}
    ;

comparador:
    MAYOR           {printf("\t\t\t\t  R36: > es Comparador\n"); strcpy(cmpAux,">");}
    |MENOR          {printf("\t\t\t\t  R37: < es Comparador\n"); strcpy(cmpAux,"<");}
    |IGUAL          {printf("\t\t\t\t  R38: == es Comparador\n"); strcpy(cmpAux,"==");}
    |DISTINTO       {printf("\t\t\t\t  R39: != es Comparador\n"); strcpy(cmpAux,"!=");}
    |MAYOR_IGUAL    {printf("\t\t\t\t  R40: >= es Comparador\n"); strcpy(cmpAux,">=");}
    |MENOR_IGUAL    {printf("\t\t\t\t  R41: <= es Comparador\n"); strcpy(cmpAux,"<=");}
    ;

expresion:
    termino {printf("\t\t\t\tR42: Termino es Expresion\n"); Eptr = Tptr;}
    |expresion OP_SUM termino {printf("\t\t\t\tR43: Expresion+Termino es Expresion\n"); Eptr = crearNodo("+", Eptr, Tptr);}
    |expresion OP_RES termino {printf("\t\t\t\tR44: Expresion-Termino es Expresion\n"); Eptr = crearNodo("-", Eptr, Tptr);}
    ;
 
termino:
    factor {printf("\t\t\t\t  R45: Factor es Termino\n"); Tptr = Fptr;}
    |OP_RES factor  {printf("\t\t\t\t  R46: -Factor es Termino\n"); Tptr = crearNodo("*", crearHoja("-1"), Fptr);}
    |termino OP_MUL factor {printf("\t\t\t\t  R47: Termino*Factor es Termino\n"); Tptr = crearNodo("*", Tptr, Fptr);}
    |termino OP_DIV factor {printf("\t\t\t\t  R48: Termino/Factor es Termino\n"); Tptr = crearNodo("/", Tptr, Fptr);}
    ;

factor:
    ID  {printf("\t\t\t\t    R50: ID es Factor \n"); 
        if(!idDeclarado(&lista, $1)){
            printf("\nError, id: *%s* no fue declarado", $1);
            return 1;
        }
         ;Fptr= crearHoja($1);}
    | INT {printf("\t\t\t\t    R51: INT es Factor\n"); Fptr= crearHoja(itoa($1, strAux, 10));  }
    | FLOAT {printf("\t\t\t\t    R52: FLOAT es Factor\n"); sprintf(strAux, "%.2f", $1); Fptr= crearHoja(strAux);}
    | PA expresion PC {printf("\t\t\t\t    R53: Expresion entre parentesis es Factor\n"); Fptr = Eptr;}
    ;
%%
 
int main(int argc, char *argv[]) {
    
    crearLista(&lista);
    crearLista(&listaIds);
    if((yyin = fopen(argv[1], "rt"))==NULL) {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else {
        yyparse();
    }
    fclose(yyin);

   

    imprimirLista(&lista);
    imprimirArbol(&compilado);
    return 0;
}
 
int yyerror() {
   
    printf("Error sintáctico\n");
    exit(1);
}

char* concatenar(char* str1, char* str2, int n){
    return strncat(str1,str2,n);
}
int estaContenido(char* str1, char* str2){

    return strstr(str1,str2) != NULL;
}