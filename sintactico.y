%{ 
    #include "libc/utilidades.h"
    #include "libc/lista_simbolos.h"
    #include "y.tab.h"
    #include "libc/arbol.h"
    #include "libc/pila.h"
    #include "libc/generar_assembler.h"

    int yystopparser = 0;
    extern FILE* yyin;

    int yyerror();
    int yylex();

    Arbol compilado;
    extern Lista listaSimbolos;
    Lista listaIds;
    Pila anidaciones;
    Pila condAnidados;
    int boolCompiladoOK = TRUE;

    NodoA* CompiladoPtr, *ProgramaPtr, *BloPtr, *ListPtr, *SentPtr, *AsigPtr, *tipoAux,
            *CicPtr, *EvalPtr, *Eptr, *StrPtr, *ConPtr, *CmpPtr, *EptrAux, *BloAux, *Tptr, *Fptr, *CmpAux, *StrPtrAux;
    NodoA* EjePtr, * ConAux, *CasePtr, *ExPtrSwitch, *FibPtr, *FibAsigPtr, *FibEjecPtr;
    
    char auxTipo[7];
    char strAux[VALOR_LARGO_MAX + 1]; 
    char strAux2[VALOR_LARGO_MAX + 2];
    char cmpAux[3];
    char opAux[3];
    char exprSwAux[5];

    int intAux;
    int cantAux = 0;
    int contAux_ = 0;
    int contAuxFinal = 0;
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
                        generarEncabezado(fp, &listaSimbolos, cantAux + contAuxFinal);
                        generarAssembler(&compilado, fp, contAuxFinal);
                        generarFin(fp);
                        fclose(fp);
                    }
                    else {
                        printf("R1: ERROR DE COMPILACION\n");
                    }
    }
    ;

programa: 
    INIT LLA declaraciones LLC bloque_ejec  { 
        printf("\tR2: init { declaraciones} bloque_ejec es Programa\n"); 
        ProgramaPtr = crearNodo("PROGRAMA", BloPtr, NULL); 
    } 
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
        BloPtr = crearNodo("BLOQ_EJEC", BloAux, SentPtr);
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
                "BLOQ_EJEC", BloPtr, crearNodo("=", crearHoja("_i"), crearNodo("+", crearHoja("_i"), crearHoja("1")))
            )
        );
    }
    |WRITE PA ID PC { 
        if(!idDeclarado(&listaSimbolos, $3)){ 
            printf("\nError, id: *%s* no fue declarado\n", $3);
            return 1;
        };
        printf("\t\tR19: write(id) es Sentencia\n");
        SentPtr = crearNodo("write", crearHoja($3), crearHoja("NULL"));
    }
    |WRITE PA STRING PC { 
        printf("\t\tR20: write(string) es Sentencia\n");
        SentPtr = crearNodo("write", crearHoja(cadenaANombre(strAux, $3)), crearHoja("NULL")); 
    }
    |READ PA ID PC      { 
        if(!idDeclarado(&listaSimbolos, $3)){ 
            printf("\nError, id: *%s* no fue declarado\n", $3);
            return 1;
        };
        printf("\t\tR21: read(id) es Sentencia\n"); 
        SentPtr = crearNodo("read", crearHoja($3), crearHoja("NULL"));
    }
    ;

asignacion:
    ID OP_AS expresion { 
        if(!idDeclarado(&listaSimbolos, $1)){ 
            printf("\nError: Id %s no fue declarado.\n", $1);
            return 1;
        };
        if(!esMismoTipo(&listaSimbolos, $1, auxTipo)){ 
            printf("\nError: Datos de diferente tipo al intentar asignar un %s al id %s.\n", auxTipo, $1);
            return 1;
        }
        printf("\t\tR22: ID = Expresion es ASIGNACION\n");
        AsigPtr = crearNodo("=", crearHoja($1), Eptr);
        if(cantAux < contAux_) {
            cantAux = contAux_;
        }
        contAux_ = 0;
    }
    |ID OP_AS string  { 
        if(!idDeclarado(&listaSimbolos, $1)){ 
            printf("\nError: Id %s no fue declarado.\n", $1);
            return 1;
        }
        if(!esMismoTipo(&listaSimbolos, $1, TSTRING)){ 
            printf("\nError: Datos de diferente tipo al intentar asignar un %s al id %s.\n", auxTipo, $1);
            return 1;
        }
        printf("\t\tR23: ID = String es ASIGNACION\n");
        AsigPtr = crearNodo("=", crearHoja($1), StrPtr);
    }
    ;

string:
    STRING  { 
        printf("\t\t\tR24: string es String\n");
        StrPtr = crearHoja(cadenaANombre(strAux, $1));
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
        desapilar(&anidaciones, &BloAux, sizeof(BloAux));   // El apilar de blo_ejec no funciona aca por que el else ejecuta otra instancia de bloque_Ejec
        EvalPtr = crearNodo("if", ConAux, crearNodo("CUERPO", BloAux, BloPtr));
    }
    |SETSWITCH PA expresion PC { 
        ExPtrSwitch = Eptr;
        snprintf(strAux, sizeof(contAuxFinal), "%d", contAuxFinal);
        strcpy(exprSwAux, "@aux");
        strcat(exprSwAux, strAux);
        contAuxFinal++;
    } cases ENDSETCASE {
        printf("\t\tR29: SET SWITCH (expresion) cases ENDSETCASE es Eval\n");
        EvalPtr = crearNodo(
            "BLOQ_EJEC",
            crearNodo("=", crearHoja(exprSwAux), ExPtrSwitch),
            CasePtr
            );
    }
    ;

cases:
    CASE INT DOS_P bloque_ejec {
        printf("\t\t\tR30: CASE INT: bloque_ejec es cases\n");
        snprintf(strAux, sizeof($2), "%d", $2);
        CasePtr = crearNodo("if", crearNodo("==", crearHoja(exprSwAux), crearHoja(strAux)), BloPtr);
    }
    |CASE INT DOS_P bloque_ejec { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } cases {
        printf("\t\t\tR31: cases CASE INT: bloque_ejec es cases\n");
        snprintf(strAux, sizeof($2), "%d", $2);
        desapilar(&anidaciones, &BloAux, sizeof(BloAux));
        CasePtr = crearNodo(
            "if",
            crearNodo("==", crearHoja(exprSwAux), crearHoja(strAux)),
            crearNodo("CUERPO", BloAux, CasePtr));
    }
    |CASE INT DOS_P bloque_ejec { apilar(&anidaciones, &BloPtr, sizeof(BloPtr)); } ELSECASE DOS_P bloque_ejec {
        printf("\t\t\tR32: CASE INT: bloque_ejec ELSECASE bloque_ejec es cases\n");
        snprintf(strAux, sizeof($2), "%d", $2);
        desapilar(&anidaciones, &BloAux, sizeof(BloAux));
        CasePtr = crearNodo(
            "if",
            crearNodo("==", crearHoja(exprSwAux), crearHoja(strAux)),
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
    expresion { EptrAux = Eptr; } comparador expresion          { 
        printf("\t\t\t\tR35: expresion comparador expresion es Comparacion \n"); 
        CmpPtr = crearNodo(cmpAux, EptrAux, Eptr); 
        contAux_ = 0;
    }
    |ESTA_CONT PA STRING { strcpy(strAux, $3); } COMA STRING PC { 
        printf("\t\t\t\tR36: estaContenido(String, String) es Comparacion\n");
        snprintf(strAux, sizeof(int), "%d", estaContenido(strAux, yylval.string_val));
        CmpPtr = crearNodo("==", crearHoja("1"), crearHoja(strAux)); 
    }
    |NOT comparacion                                            { 
        printf("\t\t\t\tR37: not comparacion es Comparacion\n");
        CmpPtr = crearNodo(
            "&", 
            crearNodo("==", crearHoja("0"), crearHoja("1")), 
            CmpPtr
        ); 
    }
    |NOT expresion                                              { 
        printf("\t\t\t\tR38: not expresion es Comparacion\n");
        CmpPtr = crearNodo(
            "&", 
            crearNodo("==", crearHoja("0"), crearHoja("1")), 
            Eptr
        ); 
    }
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
    termino                     { printf("\t\t\t\tR47: Termino es Expresion\n"); Eptr = Tptr; contAux_++; }
    |expresion OP_SUM termino   { printf("\t\t\t\tR48: Expresion+Termino es Expresion\n"); Eptr = crearNodo("+", Eptr, Tptr); contAux_++; }
    |expresion OP_RES termino   { printf("\t\t\t\tR49: Expresion-Termino es Expresion\n"); Eptr = crearNodo("-", Eptr, Tptr); contAux_++; }
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
        strcpy(auxTipo, "Int");
        Fptr= crearHoja(strAux2); 
    }
    |FLOAT { 
        printf("\t\t\t\t    R56: FLOAT es Factor\n"); 
        snprintf(strAux, VALOR_LARGO_MAX + 1, "%.2f", $1);
        //strcpy(strAux2, "_");       // strAux2 = "_"
        //strcat(strAux2, strAux);    // Ejemplo: "_2.5" para el dos punto cinco
        strcpy(auxTipo, "Float");
        Fptr= crearHoja(floatANombre(strAux));
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

        // Creo las variables o ctes a utilizar
        insertarEnLista(&listaSimbolos, "0", tINT);
        insertarEnLista(&listaSimbolos, "1", tINT);
        contAux_ += 3; // Antes @ax, @bx, @cx

        // Creo las asignaciones
        FibAsigPtr = crearNodo("BLOQ_EJEC", 
            crearNodo("=", crearHoja("@aux0"), crearHoja("_0")),  
            crearNodo("=", crearHoja("@aux1"), crearHoja("_1"))
        );

        // Creo la ejecución del ciclo
        FibPtr = crearNodo("=", crearHoja("@aux2"), crearNodo("+", crearHoja("@aux0"),  crearHoja("@aux1")));
        FibEjecPtr = crearNodo("BLOQ_EJEC", FibPtr, crearNodo("=", crearHoja("@aux0"), crearHoja("@aux1")));
        FibPtr = FibEjecPtr;
        FibEjecPtr = crearNodo("BLOQ_EJEC", FibPtr, crearNodo("=", crearHoja("@aux1"), crearHoja("@aux2")));
        FibPtr = FibEjecPtr;
        FibEjecPtr = crearNodo(
            "BLOQ_EJEC",
            FibPtr,
            crearNodo("=", crearHoja($3), crearNodo("-", crearHoja($3), crearHoja("_1")))
        );
        FibPtr = FibEjecPtr;

        // Creo el ciclo
        FibEjecPtr = crearNodo("ciclo", 
            crearNodo(">", crearHoja($3), crearHoja("_1")), //Condicion
            FibPtr
        );

        // Anidacion final
        Fptr = crearNodo(
            "@aux1",
            crearNodo("BLOQ_EJEC", FibAsigPtr, FibEjecPtr),
            crearHoja("NULL")
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