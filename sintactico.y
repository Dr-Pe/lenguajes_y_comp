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
            *CicPtr, *EvalPtr, *Eptr, *StrPtr, *ConPtr, *CmpPtr, *EptrAux, *BloAux, *Tptr, *Fptr;
    char  auxTipo[10], strAux[10], strAux2[10], cmpAux[10], opAux[10];

    char* concatenar(char*, char*, int);
    int estaContenido(char*, char*);
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
    char string_val[10];
} 
 
%%
programa_prima: 
    programa    {printf("COMPILADO\n"); compilado = ProgramaPtr;}
    ;
programa: 
    INIT LLA declaraciones LLC bloque_ejec    {printf("\tinit {declaraciones} bloque_ejec es Programa\n"); ProgramaPtr = crearNodo("Programa", DeclaPtr, BloPtr);} 
    | INIT LLA LLC bloque_ejec                      {printf("\tinit {} bloque_ejec es Programa\n"); ProgramaPtr = BloPtr;}
    ;

declaraciones: 
    dec          {printf("\tdec es Declaraciones\n"); DeclaPtr = DecPtr;}
    | declaraciones dec     {printf("\tdeclaraciones dec es Declaraciones\n"); DeclaPtr = crearNodo("Declaraciones", DeclaPtr, DecPtr);}
    ;

dec: 
    listado_ids DOS_P tipo {printf("\t\tlistado_ids : tipo es Dec\n"); DecPtr = crearNodo(":", ListPtr, crearHoja(auxTipo));}
    ;

listado_ids:
    ID                      {printf("\t\tid es Listado_ids\n"); ListPtr = crearHoja(yylval.string_val);}
    |listado_ids COMA ID    {printf("\t\tlistado_ids , id es Listado_ids\n"); ListPtr = crearNodo(",", ListPtr, crearHoja(yylval.string_val));}
    ;

tipo: DEC_INT       {printf("\t\tdec_int es Tipo\n"); strcpy(auxTipo, "int"); }
    | DEC_FLOAT     {printf("\t\tdec_float es Tipo\n"); strcpy(auxTipo, "float");}
    | DEC_STRING    {printf("\t\tdec_string es Tipo\n"); strcpy(auxTipo, "string");}
    ;

bloque_ejec: 
    sentencia                  {printf("\tsentencia es Bloque_ejec\n"); BloPtr = SentPtr;}
    | bloque_ejec sentencia            {printf("\tbloque_ejec sentencia es Bloque_ejec\n"); BloPtr = crearNodo("Union", BloPtr, SentPtr);}
    ;
sentencia:        
    asignacion                          {printf("\t\tasignacion es Sentencia\n"); SentPtr = AsigPtr;}
    |ciclo                              {printf("\t\tciclo es Sentencia\n"); SentPtr = CicPtr;}
    |eval                               {printf("\t\teval es Sentencia\n"); SentPtr = EvalPtr;}
    |TIMER PA INT COMA bloque_ejec PC   {printf("\t\ttimer(int,bloque_ejec) es Sentencia\n"); SentPtr = crearNodo("Ciclo", crearNodo("<", crearHoja("0"), crearHoja(itoa(yylval.int_val, strAux , 10))), BloPtr);}
    |WRITE PA ID PC                     {printf("\t\twrite(id) es Sentencia\n"); SentPtr = crearNodo("Write", crearHoja(yylval.string_val), crearHoja("DirMem"));}
    |WRITE PA STRING PC                 {printf("\t\twrite(string) es Sentencia\n"); SentPtr = crearNodo("Write", crearHoja(yylval.string_val), crearHoja("DirMem"));}
    |READ PA ID PC                      {printf("\t\tread(id) es Sentencia\n"); SentPtr = crearNodo(":=", crearHoja(yylval.string_val), crearHoja("READ"));}
    ;
 
asignacion:
    ID OP_AS expresion {printf("\t\tID = Expresion es ASIGNACION\n"); AsigPtr = crearNodo(":=", crearHoja(yylval.string_val),Eptr);}
    |ID OP_AS string    {printf("\t\tID = String es ASIGNACION\n"); AsigPtr = crearNodo(":=", crearHoja(yylval.string_val), StrPtr);}
    ;

string:
    STRING                                      {printf("\t\t\tstring es String\n"); StrPtr = crearHoja(yylval.string_val);}
    |CONCAT PA STRING { strcpy(strAux, yylval.string_val);} COMA STRING { strcpy(strAux2, yylval.string_val);} COMA INT PC   {printf("\t\t\ttconcatenarConRecorte(String, String, Int) es String\n"); StrPtr = crearHoja(concatenar(strAux, strAux2, yylval.int_val));}
    ;

ciclo: CICLO PA condicion PC LLA bloque_ejec LLC    {printf("\t\tciclo(Condicion) {bloque_ejec} es Ciclo\n"); CicPtr = crearNodo("Ciclo", ConPtr, BloPtr);}
    ;

eval: 
    IF PA condicion PC LLA bloque_ejec LLC                              {printf("\t\tif (condicion) {bloque_ejec} es Eval\n"); EvalPtr = crearNodo("IF", ConPtr, BloPtr);}
    |IF PA condicion PC LLA bloque_ejec cuerpo    {printf("\t\tif (condicion) {bloque_ejec} cuerpo es Eval\n"); EvalPtr = crearNodo("IF", ConPtr, crearNodo("Cuerpo", BloAux, BloPtr));}
    ;
cuerpo:
    ELSE LLA bloque_ejec LLC {printf("\t\telse {bloque_ejec} es Cuerpo"); BloAux= BloPtr;}
    ;

condicion:
    comparacion                             {printf("\t\t\tcomparacion es Condicion\n"); ConPtr = CmpPtr;}
    |comparacion {strcpy(cmpAux, CmpPtr->simbolo);} op_logico comparacion      {printf("\t\t\tcomparacion op_logico comparacion es Condicion\n"); ConPtr = crearNodo(opAux, crearHoja(cmpAux), CmpPtr);}
    ;

comparacion:
    expresion {EptrAux = Eptr;} comparador expresion          {printf("\t\t\t\texpresion comparador expresion es Comparacion\n"); CmpPtr = crearNodo(cmpAux, EptrAux, Eptr);}
    |ESTA_CONT PA STRING {strcpy(strAux, yylval.string_val);} COMA STRING PC     {printf("\t\t\t\testaContenido(String, String) es Comparacion\n"); CmpPtr = crearHoja(estaContenido(strAux, yylval.string_val)? "true" : "false" );}
    |NOT comparacion                        {printf("\t\t\t\tnot comparacion es Comparacion\n"); CmpPtr = crearNodo("&", crearHoja("false"), CmpPtr);}
    |NOT expresion                          {printf("\t\t\t\tnot expresion es Comparacion\n"); CmpPtr = crearNodo("&", crearHoja("false"), Eptr);}
    ;

op_logico:
    AND             {printf("\t\t\t\t& es Op_logico\n"); strcpy(opAux,"&");}
    |OR             {printf("\t\t\t\t|| es Op_logico\n"); strcpy(opAux,"||");}
    ;

comparador:
    MAYOR           {printf("\t\t\t\t  > es Comparador\n"); strcpy(cmpAux,">");}
    |MENOR          {printf("\t\t\t\t  < es Comparador\n"); strcpy(cmpAux,"<");}
    |IGUAL          {printf("\t\t\t\t  == es Comparador\n"); strcpy(cmpAux,"==");}
    |DISTINTO       {printf("\t\t\t\t  != es Comparador\n"); strcpy(cmpAux,"!=");}
    |MAYOR_IGUAL    {printf("\t\t\t\t  >= es Comparador\n"); strcpy(cmpAux,">=");}
    |MENOR_IGUAL    {printf("\t\t\t\t  <= es Comparador\n"); strcpy(cmpAux,"<=");}
    ;

expresion:
    termino {printf("\t\t\t\tTermino es Expresion\n"); Eptr = Tptr;}
    |expresion OP_SUM termino {printf("\t\t\t\tExpresion+Termino es Expresion\n"); Eptr = crearNodo("+", Eptr, Tptr);}
    |expresion OP_RES termino {printf("\t\t\t\tExpresion-Termino es Expresion\n"); Eptr = crearNodo("-", Eptr, Tptr);}
    ;
 
termino:
    factor {printf("\t\t\t\t  Factor es Termino\n"); Tptr = Fptr;}
    |OP_RES factor  {printf("\t\t\t\t  -Factor es Termino\n"); Tptr = crearNodo("*", crearHoja("-1"), Fptr);}
    |termino OP_MUL factor {printf("\t\t\t\t  Termino*Factor es Termino\n"); Tptr = crearNodo("*", Tptr, Fptr);}
    |termino OP_DIV factor {printf("\t\t\t\t  Termino/Factor es Termino\n"); Tptr = crearNodo("/", Tptr, Fptr);}
    ;

factor:
    ID {printf("\t\t\t\t    ID es Factor \n"); Fptr= crearHoja(yylval.string_val);}
    | INT {printf("\t\t\t\t    INT es Factor\n"); Fptr= crearHoja(yylval.string_val);  }
    | FLOAT {printf("\t\t\t\t    FLOAT es Factor\n"); Fptr= crearHoja(yylval.string_val);}
    | PA expresion PC {printf("\t\t\t\t    Expresion entre parentesis es Factor\n"); Fptr = Eptr;}
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