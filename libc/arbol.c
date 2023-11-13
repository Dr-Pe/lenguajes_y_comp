#include "arbol.h"

// Contador de Nodos para aplicar indice.
int cantNodos = 0;

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

    nuevo->indice = cantNodos++;

    return nuevo;
}

NodoA *crearHoja(char *simb)
{
    return crearNodo(simb, NULL, NULL);
}

void imprimirArbol(Arbol *pa)
{
    FILE *fp = fopen(FILENAME_DOT, "w");
    if (!fp)
    {
        printf("No se pudo abrir el archivo para escritura\n");
        return;
    }
    fprintf(fp, "digraph G{\n");
    recorrerArbolInOrdenEspejado(pa, 0, fp);
    fprintf(fp, "}\n");
    fclose(fp);
}

void recorrerArbolInOrdenEspejado(Arbol *pa, int nivel, FILE *fp)
{
    if (!*pa)
        return;

    // Creamos el nodo.
    fprintf(fp, "\"%d.%s\" [label=\"%s\"];\n", (*pa)->indice, (*pa)->simbolo,(*pa)->simbolo);

    // Si tiene, relacionamos con el hijo izquierdo.
    if ((*pa)->izq) {
        fprintf(fp, "\"%d.%s\" -> \"%d.%s\" [label=\"izq\"];\n", (*pa)->indice, (*pa)->simbolo, (*pa)->izq->indice, (*pa)->izq->simbolo);
    }

  
    // Si tiene, relacionamos con el hijo derecho.
    if ((*pa)->der) {
        fprintf(fp, "\"%d.%s\" -> \"%d.%s\" [label=\"der\"];\n", (*pa)->indice, (*pa)->simbolo, (*pa)->der->indice, (*pa)->der->simbolo);  
    }

    recorrerArbolInOrdenEspejado(&(*pa)->izq, nivel + 1, fp);
    recorrerArbolInOrdenEspejado(&(*pa)->der, nivel + 1, fp);
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