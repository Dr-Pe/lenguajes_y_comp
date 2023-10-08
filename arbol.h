#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct
{
    char simbolo[10];
} tSimbolo;

typedef struct _NodoA
{
    tSimbolo simb;
    struct _NodoA *der;
    struct _NodoA *izq;
} NodoA;

typedef NodoA *Arbol;


void crearArbol(Arbol* pa);

NodoA* crearNodo(Arbol* pa, tSimbolo simb, NodoA* hIzq, NodoA* hDer);
NodoA* crearHoja(Arbol* pa, tSimbolo simb);
void recorrerArbolInOrden(Arbol* pa);

