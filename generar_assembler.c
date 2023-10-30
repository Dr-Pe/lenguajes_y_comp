#include "generar_assembler.h"

void generarAssembler(Arbol *parbol, Lista *plista, char *filename)
{
    FILE *fp = fopen(filename, "w");
    if (!fp)
    {
        printf("\nNo se puede crear el archivo de codigo assembler.\n");
    }
    int contOps = 1;
    char aux[STRING_LARGO_MAX + 1];
    char auxOperando[VALOR_LARGO_MAX + 1];

    NodoA *nodo = padreMasIzq(parbol);
    while (nodo)
    {
        while (ES_OPERACION_ARITMETICA(nodo->simbolo))
        {
            if (strcmp(nodo->simbolo, "=") == 0)
            {
                fprintf(fp, "FLD %s\nFRNDINT\nFSTP %s\n", nodo->der->simbolo, nodo->izq->simbolo);
            }
            else if (strcmp(nodo->simbolo, "+") == 0)
            {
                fprintf(fp, "FLD %s\nFLD %s\nFADD\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contOps);
                strcpy(aux, "@aux");
                snprintf(auxOperando, sizeof(contOps), "%d", contOps);
                strcat(aux, auxOperando);
                strcpy(nodo->simbolo, aux);
            }
            else if (strcmp(nodo->simbolo, "-") == 0)
            {
                fprintf(fp, "FLD %s\nFLD %s\nFSUB\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contOps);
                strcpy(aux, "@aux");
                snprintf(auxOperando, sizeof(contOps), "%d", contOps);
                strcat(aux, auxOperando);
                strcpy(nodo->simbolo, aux);
            }
            else if (strcmp(nodo->simbolo, "*") == 0)
            {
                fprintf(fp, "FLD %s\nFLD %s\nFMUL\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contOps);
                strcpy(aux, "@aux");
                snprintf(auxOperando, sizeof(contOps), "%d", contOps);
                strcat(aux, auxOperando);
                strcpy(nodo->simbolo, aux);
            }
            else if (strcmp(nodo->simbolo, "/") == 0)
            {
                fprintf(fp, "FLD %s\nFLD %s\nFDIV\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contOps);
                strcpy(aux, "@aux");
                snprintf(auxOperando, sizeof(contOps), "%d", contOps);
                strcat(aux, auxOperando);
                strcpy(nodo->simbolo, aux);
            }
            contOps++;
            eliminarHijos(nodo);
            nodo = padreMasIzq(parbol);
        }
        contOps = 0;

        if (nodo != NULL)
        {
            eliminarHijos(nodo);
            nodo = padreMasIzq(parbol);
        }
    }

    fclose(fp);
}