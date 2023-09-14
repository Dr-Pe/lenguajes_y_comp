#include <stdlib.h>
#include <stdio.h>

#include "constantes.h"

enum tiposDato {
    tID,
    tINT,
    tFLOAT,
    tSTRING
};

typedef struct
{
    char nombre[ID_LARGO_MAX];
    char tipo_dato[7];
    char valor[40];
    int longitud;
} Simbolo;

typedef struct _Nodo
{
    Simbolo simb;
    struct _Nodo *sig;
} Nodo;

typedef Nodo *Lista;

Lista crearLista()
{
    return NULL;
}

void insertarEnLista(Lista *lista, char *nombre, enum tiposDato tDato)
{
    Simbolo nuevo_simbolo;
    
   
    nuevo_simbolo.valor[0] = '\0';
    nuevo_simbolo.longitud = 0;
    if ( tDato == tID ) {
        strcpy(nuevo_simbolo.nombre, nombre);
    }
    else if (tDato == tINT ) {
        strcpy(nuevo_simbolo.nombre, "_");
        strcat(nuevo_simbolo.tipo_dato, nombre);
    }
    else if ( tDato == tFLOAT ) {
        strcpy(nuevo_simbolo.nombre, "_");
        strcat(nuevo_simbolo.tipo_dato, nombre);
    }
    else if ( tDato == tSTRING ) {
        strcpy(nuevo_simbolo.nombre, "_");
        strcat(nuevo_simbolo.tipo_dato, nombre);
    }

    while ((*lista != NULL) && strcmp((*lista)->simb.nombre, nombre))
    {
        lista = &(*lista)->sig;
    }
    if (*lista == NULL)
    {
        Nodo *nuevo = (Nodo *)malloc(sizeof(Nodo));
        memcpy(&(nuevo->simb), &nuevo_simbolo, sizeof(Simbolo));
        nuevo->sig = NULL;
        *lista = nuevo;
    }
}

void imprimirLista(Lista *lista)
{
    while (*lista != NULL)
    {
        printf("%s,%s,%s,%d\n", (*lista)->simb.nombre, (*lista)->simb.tipo_dato, (*lista)->simb.valor, (*lista)->simb.longitud);
        lista = &(*lista)->sig;
    }
}
