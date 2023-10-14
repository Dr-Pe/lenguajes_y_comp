#include "arbol.h"

void crearArbol(Arbol* pa){
    *pa = NULL;
}

NodoA* crearNodo(char* simb, NodoA* hIzq, NodoA* hDer){

    NodoA* nuevo = (NodoA*)malloc(sizeof(NodoA));// crearNodoA(el, tam);
    if(!nuevo)
        exit(EXIT_FAILURE);

    nuevo->der = hDer;
    nuevo->izq = hIzq;
    strcpy(nuevo->simbolo, simb);
 

    return nuevo;
}


NodoA* crearHoja(char* simb){
    return crearNodo(simb, NULL, NULL);
}

void imprimirArbol(Arbol* pa){
    FILE* arch = fopen("intermediate-code.txt", "w");
    if (!arch) {
        printf("No se pudo abrir el archivo para escritura\n");
        return ;
    }
    recorrerArbolInOrden(pa, 0, arch);
    fclose(arch);
}

void recorrerArbolInOrden(Arbol* pa, int nivel, FILE* arch){
    if(!*pa)
        return;

   recorrerArbolInOrden(&(*pa)->der, nivel + 1, arch);

    for(int i = 0; i < nivel; i++)
        fprintf(arch, "\t");
    fprintf(arch, "%s\n", &(*pa)->simbolo);
    
     recorrerArbolInOrden(&(*pa)->izq, nivel + 1, arch);
}
