#ifndef _GENERAR_ASSEMBLERH_
#define _GENERAR_ASSEMBLERH_

#include "utilidades.h"
#include "lista_simbolos.h"
#include "arbol.h"
#include "pila.h"

#define TAG_VERDADERO "verdadero"
#define TAG_FALSO "falso"
#define TAG_OR "or"
#define TAG_CICLO "ciclo"

#define ES_COMPARADOR(op) (strcmp(op, "<") == 0 || strcmp(op, "<=") == 0 || strcmp(op, ">") == 0 || strcmp(op, ">=") == 0 || strcmp(op, "==") == 0 || strcmp(op, "!=") == 0)
#define ES_OP_LOGICO(op) (strcmp(op, "&") == 0 || strcmp(op, "||") == 0)

extern Lista listaSimbolos;

void generarAssembler(Arbol *parbol, FILE *fp, int contAux);
void generarComparacion(FILE *fp, NodoA *comparador, char *tag, int cont);
void invertirComparador(NodoA *nodo);
void generarIf(FILE *fp, NodoA *nodo, Pila *verdaderos, Pila *falsos, int contAux);
void generarCiclo(FILE *fp, NodoA *nodo, Pila *verdaderos, Pila *falsos, Pila *ciclos, int contAux);
void generarFin(FILE *fp);

#endif