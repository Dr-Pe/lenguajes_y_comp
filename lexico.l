%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    FILE* yyin;
    int yylval;
    char* yyltext;
    int yyerror(void);
%}

/* OPCIONES */
/* Input en un solo archivo */
%option noyywrap
/* Contador de lineas */
%option yylineno

/* TOKENS */
DIGITO      [0-9]
LETRA		[a-zA-Z]
CTE		    {DIGITO}+
STRING      \".*\"
/* Palabras reservadas */
NOT     "not"
WRITE   "write"
READ    "read"
IF      "if"
CICLO   "ciclo"
/* TODO: Agregar guiones? */
ID      {LETRA}({LETRA}|{DIGITO})*

PA      "("
PC		")"
LLA     "{"
LLC     "}"
/* Operadores aritmeticos */
OP_AS   		"="
OP_SUM		    "+"
OP_MUL          "*"
OP_RES		    "-"
OP_DIV          "/"
/* Operadores logicos */
AND     "&"
OR      "||"
MAYOR   ">"
MENOR   "<"

/**/
%% 
{CTE}			{printf("\nConstante: %s\n", yytext);}
{STRING}		{printf("\nString: %s\n", yytext);}

{NOT}			{printf("\nNot: %s\n", yytext);}
{WRITE}			{printf("\nWrite: %s\n", yytext);}
{READ}			{printf("\nRead: %s\n", yytext);}
{IF}			{printf("\nIf: %s\n", yytext);}
{CICLO}			{printf("\nCiclo: %s\n", yytext);}

{ID}			{printf("\nIdentificador: %s\n", yytext);}

{OP_SUM}		{printf("\nSuma: %s\n", yytext);}
{OP_AS}			{printf("\nAsignacion: %s\n", yytext);}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);}
{OP_RES}		{printf("\nResta: %s\n", yytext);}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);}

{PA}			{printf("\nParAbre: %s\n", yytext);}
{PC}			{printf("\nParCierra: %s\n", yytext);}
{LLA}			{printf("\nLlaveAbre: %s\n", yytext);}
{LLC}			{printf("\nLlaveCierra: %s\n", yytext);}

{AND}			{printf("\nAnd: %s\n", yytext);}
{OR}			{printf("\nOr: %s\n", yytext);}
{MAYOR}			{printf("\nMayor: %s\n", yytext);}
{MENOR}			{printf("\nMenor: %s\n", yytext);}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.   {printf("Error"); exit(1);}
%%

int main(int argc, char* argv[]) {
    yyin = fopen(argv[1], "rt");
    if(yyin == NULL) {
        printf("Error\n");
        return 1;
    }
    else {
        printf("OK\n");
        yylex();
    }
    fclose(yyin);
    return 0;
}