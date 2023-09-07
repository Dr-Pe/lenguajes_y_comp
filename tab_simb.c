#include <stdlib.h>
#include <stdio.h>

typedef struct
{
    char nombre[40];
    char tipo_dato[20];
    char valor[40];
    int longitud;
} Simbolo;

typedef struct _Nodo
{
    Simbolo simb;
    struct _Nodo *sig;
} Nodo;

typedef Nodo *Lista;

Lista *crearLista()
{
    return NULL;
}

void insertarEnLista(Lista *lista, char *nombre)
{
    Simbolo nuevo_simbolo;
    strcpy(nuevo_simbolo.nombre, nombre);
    nuevo_simbolo.longitud = 0;
    while ((lista != NULL) && strcmp((*lista)->simb.nombre, nombre))
    {
        puts("vez");
        lista = &(*lista)->sig;
    }
    if (lista == NULL)
    {
        Nodo *nuevo = (Nodo *)malloc(sizeof(Nodo));
        memcpy(&(nuevo->simb), &nuevo_simbolo, sizeof(Simbolo));
        nuevo->sig = NULL;
        *lista = nuevo;
    }
}

void imprimirLista(Lista *lista)
{
    while (lista != NULL)
    {
        printf("%s,%s,%s,%d", (*lista)->simb.nombre, (*lista)->simb.tipo_dato, (*lista)->simb.valor, (*lista)->simb.longitud);
        lista = &(*lista)->sig;
    }
}