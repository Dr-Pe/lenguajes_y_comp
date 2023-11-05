#ifndef _GENERAR_ASSEMBLERH_
#define _GENERAR_ASSEMBLERH_

#include "constantes.h"
#include "lista_simbolos.h"
#include "arbol.h"
#include "pila.h"

#define TAG_VERDADERO "verdadero"
#define TAG_FALSO "falso"
#define TAG_OR "or"

#define ES_COMPARADOR(op) (strcmp(op, "<") == 0 || strcmp(op, "<=") == 0 || strcmp(op, ">") == 0 || strcmp(op, ">=") == 0 || strcmp(op, "==") == 0 || strcmp(op, "!=") == 0)
#define ES_OP_LOGICO(op) (strcmp(op, "&") == 0 || strcmp(op, "||"))

void generarAssembler(Arbol *parbol, FILE *fp, int contAux, int contVerdadero, int contFalso, int contOr);
void generarComparacion(FILE *fp, NodoA *comparador, char *tag, int cont);
void invertirCondicion(NodoA *nodo);

#endif