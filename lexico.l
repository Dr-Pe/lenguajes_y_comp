%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "tab_simb.c"
    
    FILE* yyin;
    int yylval;
    char* yyltext;
    int yyerror(void);
    int fa_verificarRangoInt(char*);
    int fa_verificarRangoFloat(char*);
    int fa_verificarRangoStr(char*);
    Lista lista;
%}

/* OPCIONES */
/* Input en un solo archivo */
%option noyywrap
/* Contador de lineas */
%option yylineno

/* TOKENS */
DIGITO      [0-9]
LETRA		[a-zA-Z]
INT		    {DIGITO}+
FLOAT       {DIGITO}+\.{DIGITO}*|{DIGITO}*\.{DIGITO}+
STRING      \".*\"
COMENTARIO  \*-.*-\*

/* Palabras reservadas */
INIT        "init"
DEC_INT     "Int"
DEC_FLOAT   "Float"
DEC_STRING  "String"
NOT         "not"
WRITE       "write"
READ        "read"
IF          "if"
ELSE        "else"
CICLO       "ciclo"
/* TODO: Agregar guiones? */
ID          {LETRA}({LETRA}|{DIGITO})*

PA          "("
PC		    ")"
LLA         "{"
LLC         "}"
COMA        ","
DOS_P       ":"
/* Operadores aritmeticos */
OP_AS   	"="
OP_SUM		"+"
OP_MUL      "*"
OP_RES		"-"
OP_DIV      "/"
/* Operadores logicos */
AND         "&"
OR          "||"
MAYOR       ">"
MENOR       "<"

/**/
%% 

{INIT}			{printf("\nInit: %s\n", yytext);}
{DEC_INT}		{printf("\nDec int: %s\n", yytext);}
{DEC_FLOAT}		{printf("\nDec Float: %s\n", yytext);}
{DEC_STRING}	{printf("\nDec String: %s\n", yytext);}
{INT}			{fa_verificarRangoInt(yytext);printf("\nInteger: %s\n", yytext);}
{FLOAT}         {fa_verificarRangoFloat(yytext);printf("\nFloat: %s\n", yytext);}
{STRING}		{fa_verificarRangoStr(yytext);printf("\nString: %s\n", yytext);}
{COMENTARIO}    {}

{NOT}			{printf("\nNot: %s\n", yytext);}
{WRITE}			{printf("\nWrite: %s\n", yytext);}
{READ}			{printf("\nRead: %s\n", yytext);}
{IF}			{printf("\nIf: %s\n", yytext);}
{ELSE}          {printf("\nElse: %s", yytext);}
{CICLO}			{printf("\nCiclo: %s\n", yytext);}

{ID}			{insertarEnLista(&lista, yytext);}

{OP_SUM}		{printf("\nSuma: %s\n", yytext);}
{OP_AS}			{printf("\nAsignacion: %s\n", yytext);}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);}
{OP_RES}		{printf("\nResta: %s\n", yytext);}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);}

{PA}			{printf("\nParAbre: %s\n", yytext);}
{PC}			{printf("\nParCierra: %s\n", yytext);}
{LLA}			{printf("\nLlaveAbre: %s\n", yytext);}
{LLC}			{printf("\nLlaveCierra: %s\n", yytext);}
{COMA}			{printf("\nComa: %s\n", yytext);}
{DOS_P}			{printf("\nDos puntos: %s\n", yytext);}

{AND}			{printf("\nAnd: %s\n", yytext);}
{OR}			{printf("\nOr: %s\n", yytext);}
{MAYOR}			{printf("\nMayor: %s\n", yytext);}
{MENOR}			{printf("\nMenor: %s\n", yytext);}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.               {printf("Error"); exit(1);}
%%

int fa_verificarRangoInt(char* ptr) {
    long long valor = atoi(ptr);

    if ( valor < 0 || valor > 65536) {
        printf ("Error, variable Int fuera de rango");
        return 1;
    }
    return 0;
}

int fa_verificarRangoFloat(char* ptr) {
    double valor = atof(ptr);

    if ( valor < 0 || valor > 3.40e38) {
        printf ("Error, variable Float fuera de rango");
        return 1;
    }

    return 0;
}

int fa_verificarRangoStr(char* ptr) {
    long valor = strlen(ptr);

    if ( valor < 2 || valor > 42) {
        printf ("Error, variable String fuera de rango");
        return 1;
    }
    return 0;
}

int main(int argc, char* argv[]) {
    yyin = fopen(argv[1], "rt");
    if(yyin == NULL) {
        printf("Error\n");
        return 1;
    }
    else {
        lista = crearLista();
        printf("OK\n");
        yylex();
        imprimirLista(&lista);
    }


    fclose(yyin);
    return 0;
}
