#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "constantes.h"

enum tiposDato
{
    tID,
    tINT,
    tFLOAT,
    tSTRING
};

typedef struct
{
    char nombre[ID_LARGO_MAX + 2];
    char tipo_dato[TIPO_DATO_LARGO_MAX];
    char valor[VALOR_LARGO_MAX];
    int longitud;
} Simbolo;

typedef struct _Nodo
{
    Simbolo simb;
    struct _Nodo *sig;
} Nodo;

typedef Nodo *Lista;

Lista crearLista(Lista *pl);
void insertarEnLista(Lista *lista, char *nombre, enum tiposDato tDato);
void imprimirLista(Lista *lista);

Lista listaSimbolos;

int idDeclarado(Lista *lista, char *var1);
void asignarTipoDato(Lista *lista, char *id, char *tipoDato);
void vaciarLista(Lista *pl);
void asignarTipo(Lista *listaIds, char *auxTipo);
void fusionarLista(Lista *lista1, Lista *lista2);