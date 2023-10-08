#include "arbol.h"

void crearArbol(Arbol* pa){
    *pa = NULL;
}

NodoA* crearNodo(Arbol* pa, tSimbolo simb, NodoA* hIzq, NodoA* hDer){

    NodoA* nuevo = (NodoA*)malloc(sizeof(NodoA));// crearNodoA(el, tam);
    if(!nuevo)
        exit(EXIT_FAILURE);

    nuevo->der = hDer;
    nuevo->izq = hIzq;
    strcpy(nuevo->simb.simbolo, simb.simbolo);
    *pa = nuevo;

    return nuevo;
}
NodoA* crearHoja(Arbol* pa, tSimbolo simb){
    return crearNodo(pa, simb, NULL, NULL);
}

void recorrerArbolInOrden(Arbol* pa){
    if(!*pa)
        return;

    recorrerArbolInOrden(&(*pa)->izq);
    printf("%s ", &(*pa)->simb.simbolo);
    recorrerArbolInOrden(&(*pa)->der);
}
