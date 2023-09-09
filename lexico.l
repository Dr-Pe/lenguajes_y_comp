%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "tab_simb.c"
    #include "y.tab.h"
    
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
/* ID, TODO: Agregar guiones? */
ID          {LETRA}({LETRA}|{DIGITO})*
/* Caracteres especiales */
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

/* Reglas */
%% 
{INIT}          {printf("\nInit: %s\n", yytext); return INIT;}
{DEC_INT}       {printf("\nDec int: %s\n", yytext); return DEC_INT;}
{DEC_FLOAT}     {printf("\nDec Float: %s\n", yytext); return DEC_FLOAT;}
{DEC_STRING}    {printf("\nDec String: %s\n", yytext); return DEC_STRING;}
{INT}           {fa_verificarRangoInt(yytext);printf("\nInteger: %s\n", yytext); return INT;}
{FLOAT}         {fa_verificarRangoFloat(yytext);printf("\nFloat: %s\n", yytext); return FLOAT;}
{STRING}        {fa_verificarRangoStr(yytext);printf("\nString: %s\n", yytext); return STRING;}
{COMENTARIO}    {}
 
{NOT}           {printf("\nNot: %s\n", yytext); return NOT;}
{WRITE}         {printf("\nWrite: %s\n", yytext); return WRITE;}
{READ}          {printf("\nRead: %s\n", yytext); return READ;}
{IF}            {printf("\nIf: %s\n", yytext); return IF;}
{ELSE}          {printf("\nElse: %s", yytext); return ELSE;}
{CICLO}         {printf("\nCiclo: %s\n", yytext); return CICLO;}
 
{ID}            {insertarEnLista(&lista, yytext); return ID;}
 
{OP_SUM}        {printf("\nSuma: %s\n", yytext); return OP_SUM;}
{OP_AS}         {printf("\nAsignacion: %s\n", yytext); return OP_AS;}
{OP_MUL}        {printf("\nMultiplicacion: %s\n", yytext); return OP_MUL;}
{OP_RES}        {printf("\nResta: %s\n", yytext); return OP_RES;}
{OP_DIV}        {printf("\nDivision: %s\n", yytext); return OP_DIV;}
 
{PA}            {printf("\nParAbre: %s\n", yytext); return PA;}
{PC}            {printf("\nParCierra: %s\n", yytext); return PC;}
{LLA}           {printf("\nLlaveAbre: %s\n", yytext); return LLA;}
{LLC}           {printf("\nLlaveCierra: %s\n", yytext); return LLC;}
{COMA}          {printf("\nComa: %s\n", yytext); return COMA;}
{DOS_P}         {printf("\nDos puntos: %s\n", yytext); return DOS_P;}
 
{AND}           {printf("\nAnd: %s\n", yytext); return AND;}
{OR}            {printf("\nOr: %s\n", yytext); return OR;}
{MAYOR}         {printf("\nMayor: %s\n", yytext); return MAYOR;}
{MENOR}         {printf("\nMenor: %s\n", yytext); return MENOR;}

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

// int main(int argc, char* argv[]) {
//     yyin = fopen(argv[1], "rt");
//     if(yyin == NULL) {
//         printf("Error\n");
//         return 1;
//     }
//     else {
//         lista = crearLista();
//         printf("OK\n");
//         yylex();
//         imprimirLista(&lista);
//     }


//     fclose(yyin);
//     return 0;
// }
