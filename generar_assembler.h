#ifndef _GENERAR_ASSEMBLERH_
#define _GENERAR_ASSEMBLERH_

#include "constantes.h"
#include "lista_simbolos.h"
#include "arbol.h"
#include "pila.h"

#define ES_COMPARADOR(op) (strcmp(op, "<") == 0 || strcmp(op, "<=") == 0 || strcmp(op, ">") == 0 || strcmp(op, ">=") == 0 || strcmp(op, "==") == 0 || strcmp(op, "!=") == 0)

void generarAssembler(Arbol *parbol, FILE *fp, int contAux, int contVerdadero, int contFalso);

#endif