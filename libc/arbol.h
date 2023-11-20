#ifndef _ARBOLH_
#define _ARBOLH_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "utilidades.h"

#define ES_COMPARADOR(op) (strcmp(op, "<") == 0 || strcmp(op, "<=") == 0 || strcmp(op, ">") == 0 || strcmp(op, ">=") == 0 || strcmp(op, "==") == 0 || strcmp(op, "!=") == 0)
#define ES_OP_LOGICO(op) (strcmp(op, "&") == 0 || strcmp(op, "||") == 0)

typedef struct _NodoA
{
    char simbolo[VALOR_LARGO_MAX + 1];
    struct _NodoA *der;
    struct _NodoA *izq;
    int indice;
    char tipo[TIPO_DATO_LARGO_MAX + 1];
} NodoA;

typedef NodoA *Arbol;

void crearArbol(Arbol *pa);
NodoA *crearNodo(char *simb, NodoA *hIzq, NodoA *hDer);
NodoA *crearHoja(char *simb);
void imprimirArbol(Arbol *pa);
void recorrerArbolInOrdenEspejado(Arbol *pa, int nivel, FILE *fp);
void vaciarArbol(Arbol *pa);
NodoA *padreMasIzq(Arbol *pa);
void eliminarHijos(NodoA *pa);
void actualizarTipoNodo(NodoA *pa, char* tipo);

#endif