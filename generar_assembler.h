#ifndef _GENERAR_ASSEMBLERH_
#define _GENERAR_ASSEMBLERH_

#include "constantes.h"
#include "lista_simbolos.h"
#include "arbol.h"
#include "pila.h"

#define ES_OPERACION_ARITMETICA(op) (strcmp(op, "+") == 0 || strcmp(op, "-") == 0 || strcmp(op, "*") == 0 || strcmp(op, "/") == 0 || strcmp(op, "=") == 0)

void generarAssembler(Arbol *parbol, Lista *plista, char *filename);

#endif