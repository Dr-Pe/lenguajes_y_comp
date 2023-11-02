#include "generar_assembler.h"

#define TAG_VERDADERO "verdadero"
#define TAG_FALSO "falso"

void generarAssembler(Arbol *parbol, FILE *fp, int contAux, int contVerdadero, int contFalso)
{
    int numeroAuxiliar;
    char aux[STRING_LARGO_MAX + 1];
    char auxOperando[VALOR_LARGO_MAX + 1];
    Pila verdaderos = crearPila(&verdaderos);
    Pila falsos = crearPila(&falsos);

    NodoA *nodo = padreMasIzq(parbol);
    while (nodo)
    {

        if (strcmp(nodo->simbolo, "BloqEjec") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdadero, contFalso);
        }
        else if (strcmp(nodo->simbolo, "=") == 0)
        {
            fprintf(fp, "FLD %s\nFRNDINT\nFSTP %s\n", nodo->der->simbolo, nodo->izq->simbolo);
        }
        else if (strcmp(nodo->simbolo, "+") == 0)
        {
            fprintf(fp, "FLD %s\nFLD %s\nFADD\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
        }
        else if (strcmp(nodo->simbolo, "-") == 0)
        {
            fprintf(fp, "FLD %s\nFLD %s\nFSUB\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
        }
        else if (strcmp(nodo->simbolo, "*") == 0)
        {
            fprintf(fp, "FLD %s\nFLD %s\nFMUL\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
        }
        else if (strcmp(nodo->simbolo, "/") == 0)
        {
            fprintf(fp, "FLD %s\nFLD %s\nFDIV\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
        }
        else if (strcmp(nodo->simbolo, "if") == 0)
        {

            if (strcmp(nodo->der->simbolo, "Cuerpo") == 0)
            {
                generarAssembler(&nodo->der->izq, fp, contAux, contVerdadero, contFalso); // True
                contVerdadero++;
                apilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
                fprintf(fp, "BI %s%d\n", TAG_VERDADERO, contVerdadero);
                desapilar(&falsos, &numeroAuxiliar, sizeof(numeroAuxiliar));
                fprintf(fp, "%s%d\n", TAG_FALSO, numeroAuxiliar);
                generarAssembler(&nodo->der->der, fp, contAux, contVerdadero, contFalso); // False
                desapilar(&verdaderos, &numeroAuxiliar, sizeof(numeroAuxiliar));
                fprintf(fp, "%s%d\n", TAG_VERDADERO, numeroAuxiliar);
            }
            else
            {
                generarAssembler(&nodo->der, fp, contAux, contVerdadero, contFalso);
                desapilar(&falsos, &numeroAuxiliar, sizeof(numeroAuxiliar));
                fprintf(fp, "%s%d\n", TAG_FALSO, numeroAuxiliar);
            }
        }
        else if (ES_COMPARADOR(nodo->simbolo))
        {
            fprintf(fp, "FLD %s\n", nodo->izq->simbolo);
            fprintf(fp, "FCOMP %s\n", nodo->der->simbolo);
            fprintf(fp, "FSTSW ax\n"); // Los flags del coprocesador en memoria
            fprintf(fp, "SAHF\n");     // Guardo los flags que estan en memoria en el registro FLAG del cpu
            if (strcmp(nodo->simbolo, "<") == 0)
            {
                fprintf(fp, "JNB %s%d\n", TAG_FALSO, contFalso); // ini
            }
            else if (strcmp(nodo->simbolo, ">") == 0)
            {
                fprintf(fp, "JBE %s%d\n", TAG_FALSO, contFalso);
            }
            else if (strcmp(nodo->simbolo, "<=") == 0)
            {
                fprintf(fp, "JNBE %s%d\n", TAG_FALSO, contFalso);
            }
            else if (strcmp(nodo->simbolo, ">=") == 0)
            {
                fprintf(fp, "JNAE %s%d\n", TAG_FALSO, contFalso);
            }
            else if (strcmp(nodo->simbolo, "!=") == 0)
            {
                fprintf(fp, "JE %s%d\n", TAG_FALSO, contFalso);
            }
            else if (strcmp(nodo->simbolo, "==") == 0)
            {
                fprintf(fp, "JNE %s%d\n", TAG_FALSO, contFalso);
            }
            apilar(&falsos, &contFalso, sizeof(contFalso));
            contFalso++;
        }
        if (strcmp(nodo->simbolo, "Write") == 0)
        {
            // TODO:
            fprintf(fp, "WRITE %s\n", nodo->izq->simbolo);
        }

        contAux++;
        eliminarHijos(nodo);
        nodo = padreMasIzq(parbol);
    }
}