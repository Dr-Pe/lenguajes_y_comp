%{ 
    #include "constantes.h"
    #include "lista_simbolos.h"
    #include "y.tab.h"
    #include "arbol.h"
    #include "pila.h"
    #include "generar_assembler.h"

    int yystopparser=0;
    extern FILE* yyin;

    int yyerror();
    int yylex();

    char* concatenar(char* str1, char* str2, int n);
    int estaContenido(char* str1, char* str2);

    Arbol compilado;
    Lista listaSimbolos;
    Lista listaIds;
    Pila anidaciones;
    Pila condAnidados;
    int boolCompiladoOK = 1;

    NodoA* CompiladoPtr, *ProgramaPtr, *BloPtr, *ListPtr, *SentPtr, *AsigPtr, *tipoAux,
            *CicPtr, *EvalPtr, *Eptr, *StrPtr, *ConPtr, *CmpPtr, *EptrAux, *BloAux, *Tptr, *Fptr, *CmpAux, *StrPtrAux;
    NodoA* EjePtr, * ConAux, *CasePtr, *ExPtrSwitch, *FibPtr, *FibAsigPtr, *FibEjecPtr;
    char  auxTipo[7], strAux[VALOR_LARGO_MAX + 1], strAux2[VALOR_LARGO_MAX + 2], cmpAux[3], opAux[3];
    int intAux;
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
%token FIB          // Agregada grupo 6
%token SETSWITCH    // Agregada grupo 6
%token CASE
%token ELSECASE
%token ENDSETCASE
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
    programa    { 
                    compilado = ProgramaPtr; 
                    if(boolCompiladoOK == 1) {
                        printf("R1: COMPILACION EXITOSA\n");
                        imprimirArbol(&compilado);
                        FILE *fp = fopen(FILENAME_ASM, "w");
                        if (!fp) {
                        printf("\nNo se puede crear el archivo de codigo assembler.\n");
                        }
                        generarEncabezado(fp, &listaSimbolos);
                        generarAssembler(&compilado, fp, 0, 0, 0);
                        fclose(fp);
                    }
                    else {
                        printf("R1: ERROR DE COMPILACION\n");
                    }
    }
    ;

programa: 
    INIT LLA declaraciones LLC bloque_ejec  { printf("\tR2: init { declaraciones} bloque_ejec es Programa\n"); ProgramaPtr = crearNodo("Programa", BloPtr, NULL); } 
    |INIT LLA LLC bloque_ejec               { printf("\tR3: init { } bloque_ejec es Programa\n"); ProgramaPtr = BloPtr; }
    |INIT LLA declaraciones LLC             { printf("\tR4: init { declaraciones } es Programa\n"); ProgramaPtr = BloPtr; }
    ;

declaraciones: 
    dec                 { printf("\tR5: dec es Declaraciones\n"); }
    |declaraciones dec  { printf("\tR6: declaraciones dec es Declaraciones\n"); }
    ;

dec: 
    listado_ids DOS_P tipo  { 
        printf("\t\tR7: listado_ids : tipo es Dec\n");
        asignarTipo(&listaIds, auxTipo);
        fusionarLista(&listaSimbolos, &listaIds);
        vaciarLista(&listaIds);
    }
    ;

listado_ids:
    ID  { 
        printf("\tR8: id es Listado_ids\n");
        insertarEnLista(&listaIds, $1, tID);
        ListPtr = crearHoja($1);
    }
    |listado_ids COMA ID    { 
        printf("\t\tR9: listado_ids , id es Listado_ids\n"); 
        insertarEnLista(&listaIds, $3, tID); 
        ListPtr = crearNodo(",", ListPtr, crearHoja($3));
    }
    ;

tipo: 
    DEC_INT     { printf("\t\tR10: dec_int es Tipo\n"); strcpy(auxTipo, TINT); }
    |DEC_FLOAT  { printf("\t\tR11: dec_float es Tipo\n"); strcpy(auxTipo, TFLOAT); }
    |DEC_STRING { printf("\t\tR12: dec_string es Tipo\n"); strcpy(auxTipo, TSTRING); }
    ;

bloque_ejec: 
    sentencia { printf("\tR13: sentencia es Bloque_ejec\n"); BloPtr = SentPtr; }
    |bloque_ejec { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } sentencia { 
        printf("\tR14: bloque_ejec sentencia es Bloque_ejec\n"); 
        desapilar(&anidaciones, &BloAux, sizeof(BloAux));
        BloPtr = crearNodo("BloqEjec", BloAux, SentPtr);
    }
    ;

sentencia:        
    asignacion  { printf("\t\tR15: asignacion es Sentencia\n"); SentPtr = AsigPtr; }
    |ciclo      { printf("\t\tR16: ciclo es Sentencia\n"); SentPtr = CicPtr; }
    |eval       { printf("\t\tR17: eval es Sentencia\n"); SentPtr = EvalPtr; }
    |TIMER PA INT { intAux = yylval.int_val; } COMA bloque_ejec PC { 
        printf("\t\tR18: timer(int,bloque_ejec) es Sentencia\n");
        snprintf(strAux, sizeof(intAux), "%d", intAux);
        SentPtr = crearNodo(
            "ciclo", 
            crearNodo("<", crearHoja("_i"), crearHoja(strAux)),
            crearNodo(
                "BloqEjec", BloPtr, crearNodo("=", crearHoja("_i"), crearNodo("+", crearHoja("_i"), crearHoja("1")))
            )
        );
    }
    |WRITE PA ID PC { 
        if(!idDeclarado(&listaSimbolos, $3)){ 
            printf("\nError, id: *%s* no fue declarado\n", $3);
            return 1;
        };
        printf("\t\tR19: write(id) es Sentencia\n");
        SentPtr = crearNodo("Write", crearHoja($3), crearHoja("DirMem"));
    }
    |WRITE PA STRING PC { printf("\t\tR20: write(string) es Sentencia\n"); SentPtr = crearNodo("Write", crearHoja($3), crearHoja("DirMem")); }
    |READ PA ID PC      { 
        if(!idDeclarado(&listaSimbolos, $3)){ 
            printf("\nError, id: *%s* no fue declarado\n", $3);
            return 1;
        };
        printf("\t\tR21: read(id) es Sentencia\n"); 
        SentPtr = crearNodo("=", crearHoja($3), crearHoja("READ"));
    }
    ;

asignacion:
    ID OP_AS expresion { 
        if(!idDeclarado(&listaSimbolos, $1)){ 
            printf("\nError, id: *%s* no fue declarado\n", $1);
            return 1;
        };
        if(!esMismoTipo(&listaSimbolos, $1, auxTipo)){ 
            printf("\nError, datos de diferente tipo.\n");
            return 1;
        }
        printf("\t\tR22: ID = String es ASIGNACION\n");
        AsigPtr = crearNodo("=", Eptr, crearHoja($1));
    }
    |ID OP_AS string  { 
        if(!idDeclarado(&listaSimbolos, $1)){ 
            printf("\nError, id: *%s* no fue declarado\n", $1);
            return 1;
        }
        if(!esMismoTipo(&listaSimbolos, $1, TSTRING)){ 
            printf("\nError, datos de diferente tipo.\n");
            return 1;
        }
        printf("\t\tR23: ID = String es ASIGNACION\n");
        AsigPtr = crearNodo("=", StrPtr, crearHoja($1));
    }
    ;

string:
    STRING  { 
        printf("\t\t\tR24: string es String\n");
        StrPtr = crearHoja($1);
        strcpy(auxTipo, TSTRING);
    }
    |CONCAT PA STRING { strcpy(strAux, $3); } COMA STRING { strcpy(strAux2, $6); } COMA INT PC { 
        printf("\t\t\tR25: concatenarConRecorte(String, String, Int) es String\n"); 
        StrPtr = crearHoja(concatenar(strAux, strAux2, yylval.int_val));
    }
    ;


ciclo: 
    CICLO PA condicion  PC LLA bloque_ejec  LLC    { 
        desapilar(&condAnidados, &ConAux, sizeof(ConAux));
        printf("\t\tR26: ciclo(Condicion) { bloque_ejec} es Ciclo\n"); CicPtr = crearNodo("ciclo", ConAux, BloPtr);
    }
    ;

eval: 
    IF PA condicion PC LLA bloque_ejec LLC { 
        printf("\t\tR27: if (condicion) { bloque_ejec} es Eval\n"); 
        desapilar(&condAnidados, &ConAux, sizeof(ConAux));
        EvalPtr = crearNodo("if", ConAux, BloPtr);
    }
    |IF PA condicion PC LLA bloque_ejec LLC { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } ELSE LLA bloque_ejec LLC { 
        printf("\t\tR28: if (condicion) { bloque_ejec} else { bloque_ejec} es Eval\n"); 
        desapilar(&condAnidados, &ConAux, sizeof(ConAux));
        desapilar(&anidaciones, &BloAux, sizeof(BloAux));   // el apilar de blo_ejec no funciona aca por que el else ejecuta otra instancia de bloque_Ejec
        EvalPtr = crearNodo("if", ConAux, crearNodo("Cuerpo", BloAux, BloPtr));
    }
    |SETSWITCH PA expresion PC { ExPtrSwitch = Eptr; } cases ENDSETCASE {
        printf("\t\tR29: SET SWITCH (expresion) cases ENDSETCASE es Eval\n");
        EvalPtr = crearNodo(
            "BloqEjec", 
            crearNodo("=", crearHoja("@ax"), ExPtrSwitch),
            CasePtr
            );
    }
    ;

cases:
    CASE INT DOS_P bloque_ejec {
        printf("\t\t\tR30: CASE INT: bloque_ejec es cases\n");
        snprintf(strAux, sizeof($2), "%d", $2);
        CasePtr = crearNodo("if", crearNodo("==", crearHoja("@ax"), crearHoja(strAux)), BloPtr);
    }
    |CASE INT DOS_P bloque_ejec { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } cases {
        printf("\t\t\tR31: cases CASE INT: bloque_ejec es cases\n");
        snprintf(strAux, sizeof($2), "%d", $2);
        desapilar(&anidaciones, &BloAux, sizeof(BloAux));
        CasePtr = crearNodo(
            "if",
            crearNodo("==", crearHoja("@ax"), crearHoja(strAux)),
            crearNodo("CUERPO", BloAux, CasePtr));
    }
    |CASE INT DOS_P bloque_ejec { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } ELSECASE DOS_P bloque_ejec {
        printf("\t\t\tR32: CASE INT: bloque_ejec ELSECASE bloque_ejec es cases\n");
        snprintf(strAux, sizeof($2), "%d", $2);
        desapilar(&anidaciones, &BloAux, sizeof(BloAux));
        CasePtr = crearNodo(
            "if",
            crearNodo("==", crearHoja("@ax"), crearHoja(strAux)),
            crearNodo("CUERPO", BloAux, BloPtr));
    }
    ;

condicion:
    comparacion { 
        printf("\t\t\tR33: comparacion es Condicion\n"); 
        ConPtr = CmpPtr;
        apilar(&condAnidados, &ConPtr, sizeof(ConPtr));
    }
    |comparacion { CmpAux = CmpPtr; } op_logico comparacion { 
        printf("\t\t\tR34: comparacion op_logico comparacion es Condicion\n"); 
        ConPtr = crearNodo(opAux, CmpAux, CmpPtr);
        apilar(&condAnidados, &ConPtr, sizeof(ConPtr));
    }
    ;

comparacion:
    expresion { EptrAux = Eptr; } comparador expresion          { printf("\t\t\t\tR35: expresion comparador expresion es Comparacion \n"); CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); }
    |ESTA_CONT PA STRING { strcpy(strAux, $3); } COMA STRING PC { printf("\t\t\t\tR36: estaContenido(String, String) es Comparacion\n"); CmpPtr = crearHoja(estaContenido(strAux, yylval.string_val)? "true" : "false" ); }
    |NOT comparacion                                            { printf("\t\t\t\tR37: not comparacion es Comparacion\n"); CmpPtr = crearNodo("&", crearHoja("false"), CmpPtr); }
    |NOT expresion                                              { printf("\t\t\t\tR38: not expresion es Comparacion\n"); CmpPtr = crearNodo("&", crearHoja("false"), Eptr); }
    ;

op_logico:
    AND             { printf("\t\t\t\tR39: & es Op_logico\n"); strcpy(opAux,"&"); }
    |OR             { printf("\t\t\t\tR40: ||es Op_logico\n"); strcpy(opAux,"||"); }
    ;

comparador:
    MAYOR           { printf("\t\t\t\t  R41: > es Comparador\n"); strcpy(cmpAux,">"); }
    |MENOR          { printf("\t\t\t\t  R42: < es Comparador\n"); strcpy(cmpAux,"<"); }
    |IGUAL          { printf("\t\t\t\t  R43: == es Comparador\n"); strcpy(cmpAux,"=="); }
    |DISTINTO       { printf("\t\t\t\t  R44: != es Comparador\n"); strcpy(cmpAux,"!="); }
    |MAYOR_IGUAL    { printf("\t\t\t\t  R45: >= es Comparador\n"); strcpy(cmpAux,">="); }
    |MENOR_IGUAL    { printf("\t\t\t\t  R46: <= es Comparador\n"); strcpy(cmpAux,"<="); }
    ;

expresion:
    termino                     { printf("\t\t\t\tR47: Termino es Expresion\n"); Eptr = Tptr; }
    |expresion OP_SUM termino   { printf("\t\t\t\tR48: Expresion+Termino es Expresion\n"); Eptr = crearNodo("+", Eptr, Tptr); }
    |expresion OP_RES termino   { printf("\t\t\t\tR49: Expresion-Termino es Expresion\n"); Eptr = crearNodo("-", Eptr, Tptr); }
    ;
 
termino:
    factor                  { printf("\t\t\t\t  R50: Factor es Termino\n"); Tptr = Fptr; }
    |OP_RES factor          { printf("\t\t\t\t  R51: -Factor es Termino\n"); Tptr = crearNodo("*", crearHoja("-1"), Fptr); }
    |termino OP_MUL factor  { printf("\t\t\t\t  R52: Termino*Factor es Termino\n"); Tptr = crearNodo("*", Tptr, Fptr); }
    |termino OP_DIV factor  { printf("\t\t\t\t  R53: Termino/Factor es Termino\n"); Tptr = crearNodo("/", Tptr, Fptr); }
    ;

factor:
    ID  { 
        if(!idDeclarado(&listaSimbolos, $1)){ 
            printf("\nError, id: *%s* no fue declarado\n", $1);
            return 1;
        }
        if(esMismoTipo(&listaSimbolos, $1, TSTRING)){ 
            printf("\nError: No es posible realizar operaciones aritmeticas sobre variables String.\n");
            return 1;
        }
        printf("\t\t\t\t    R54: ID es Factor \n");
        strcpy(auxTipo, obtenerTipo(&listaSimbolos, $1)); // Se copia en auxTipo el tipo de la ID (Ojo cuando escala a termino y se pisa)
        Fptr= crearHoja($1); 
    }
    |INT   { 
        printf("\t\t\t\t    R55: INT es Factor\n"); 
        snprintf(strAux, sizeof($1), "%d", $1);
        strcpy(strAux2, "_");       // strAux2 = "_"
        strcat(strAux2, strAux);    // Ejemplo: "_2" para el dos
        strcpy(auxTipo, TINT);
        Fptr= crearHoja(strAux2); 
    }
    |FLOAT { 
        printf("\t\t\t\t    R56: FLOAT es Factor\n"); 
        snprintf(strAux, VALOR_LARGO_MAX + 1, "%.2f", $1);
        strcpy(strAux2, "_");       // strAux2 = "_"
        strcat(strAux2, strAux);    // Ejemplo: "_2.5" para el dos punto cinco
        strcpy(auxTipo, TFLOAT);
        Fptr= crearHoja(strAux2);
    }
    |PA expresion PC    { printf("\t\t\t\t    R57: Expresion entre parentesis es Factor\n"); Fptr = Eptr; }
    |FIB PA ID PC       { 
        if(!idDeclarado(&listaSimbolos, $3)){ 
            printf("\nError: id *%s* no fue declarado.\n", $3);
            return 1;
        }
        if(!esMismoTipo(&listaSimbolos, $3, TINT)){ 
            printf("\nError: id *%s* no es de tipo Int.\n", $3);
            return 1;
        }
        printf("\t\t\t\t    R58: FIB(ID) es Factor\n");

        // Creo las asignaciones
        FibAsigPtr = crearNodo("BloqAsig", 
            crearNodo("=", crearHoja("@ax"), crearHoja("0")),  
            crearNodo("=", crearHoja("@bx"), crearHoja("1"))
        );

        // Creo la ejecución del ciclo
        FibPtr = crearNodo("=", crearHoja("@cx"), crearNodo("+", crearHoja("@ax"),  crearHoja("@bx")));
        FibEjecPtr = crearNodo("BloqEjec", FibPtr, crearNodo("=", crearHoja("@ax"), crearHoja("@bx")));
        FibPtr = FibEjecPtr;
        FibEjecPtr = crearNodo("BloqEjec", FibPtr, crearNodo("=", crearHoja("@bx"), crearHoja("@cx")));
        FibPtr = FibEjecPtr;
        FibEjecPtr = crearNodo("BloqEjec",
            FibPtr,
            crearNodo("=", crearHoja($3), crearNodo("-", crearHoja($3), crearHoja("1")))
        );
        FibPtr = FibEjecPtr;

        // Creo el ciclo
        FibEjecPtr = crearNodo("ciclo", 
            crearNodo(">", crearHoja($3), crearHoja("1")), //Condicion
            FibPtr
        );

        // Anidacion final
        Fptr = crearNodo("BloqEjec", 
            crearNodo("BloqEjec", FibAsigPtr, FibEjecPtr),
            crearNodo("=", crearHoja("FIB"), crearHoja("@bx"))
        );
    }
    ;
%%
 
int main(int argc, char *argv[]) { 
    crearLista(&listaSimbolos);
    crearLista(&listaIds);
    crearPila(&anidaciones);
    crearPila(&condAnidados);

    if((yyin = fopen(argv[1], "rt"))==NULL) { 
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else { 
        yyparse();
    }
    fclose(yyin);

    imprimirLista(&listaSimbolos);
    
    vaciarLista(&listaSimbolos);
    vaciarLista(&listaIds);
    vaciarPila(&anidaciones);
    vaciarPila(&condAnidados);
    vaciarArbol(&compilado);
    return 0;
}
 
int yyerror() { 
    printf("Error sintáctico\n");
    exit(1);
}

char* concatenar(char* str1, char* str2, int n) { 

    if(strlen(str1) <= n+2 ||strlen(str2) <= n+2){  //+2 por ""
        return "ERROR";
    } 


    char aux [strlen(str1) + strlen(str2) + 3]; //si n=0
    aux[0] = '"';

    strcpy(aux+ 1, str1+n+1); 
    strcpy(aux + strlen(aux) - 1, str2+n+1);  
    strcpy(str1, aux);

    if(strlen(str1) >= STRING_LARGO_MAX + 3 ){   //+3 "" \0
        return "ERROR";
    }
   
    return str1;
}

int estaContenido(char* str1, char* str2) { 
    return strstr(str1,str2) != NULL;
}