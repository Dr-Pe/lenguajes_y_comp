#include "arbol.h"

void crearArbol(Arbol *pa)
{
    *pa = NULL;
}

NodoA *crearNodo(char *simb, NodoA *hIzq, NodoA *hDer)
{

    NodoA *nuevo = (NodoA *)malloc(sizeof(NodoA)); // crearNodoA(el, tam);
    if (!nuevo)
        exit(EXIT_FAILURE);

    nuevo->der = hDer;
    nuevo->izq = hIzq;
    strcpy(nuevo->simbolo, simb);

    return nuevo;
}

NodoA *crearHoja(char *simb)
{
    return crearNodo(simb, NULL, NULL);
}

void imprimirArbol(Arbol *pa)
{
    FILE *arch = fopen("intermediate-code.txt", "w");
    if (!arch)
    {
        printf("No se pudo abrir el archivo para escritura\n");
        return;
    }
    recorrerArbolInOrdenEspejado(pa, 0, arch);
    fclose(arch);
}

void recorrerArbolInOrdenEspejado(Arbol *pa, int nivel, FILE *arch)
{
    if (!*pa)
        return;

    recorrerArbolInOrdenEspejado(&(*pa)->der, nivel + 1, arch);

    for (int i = 0; i < nivel; i++)
        fprintf(arch, "\t");
    fprintf(arch, "%s\n", (*pa)->simbolo);

    recorrerArbolInOrdenEspejado(&(*pa)->izq, nivel + 1, arch);
}

void vaciarArbol(Arbol *pa)
{
    if (!*pa)
        return;

    vaciarArbol(&(*pa)->izq);
    vaciarArbol(&(*pa)->der);
    free(*pa);
    *pa = NULL;
}

NodoA *padreMasIzq(Arbol *pa)
{
    if (!*pa)
        return NULL;

    NodoA *res = padreMasIzq(&(*pa)->izq);
    if (res)
        return res;

    if ((*pa)->izq && (*pa)->der && !ES_COMPARADOR((*pa)->simbolo))
        return *pa;

    res = padreMasIzq(&(*pa)->der);
    if (res)
        return res;

    return NULL;
}

void eliminarHijos(NodoA *pa)
{
    if (!pa)
    {
        return;
    }
    if (pa->izq)
    {
        free(pa->izq);
        pa->izq = NULL;
    }
    if (pa->der)
    {
        free(pa->der);
        pa->der = NULL;
    }
}