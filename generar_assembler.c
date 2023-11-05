#include "generar_assembler.h"

void generarAssembler(Arbol *parbol, FILE *fp, int contAux, int contVerdadero, int contFalso, int contOr)
{
    int numeroAuxiliar;
    char aux[STRING_LARGO_MAX + 1];
    char auxOperando[VALOR_LARGO_MAX + 1];
    Pila verdaderos = crearPila(&verdaderos);
    Pila falsos = crearPila(&falsos);
    Pila ors = crearPila(&ors);
    int operadorOr = 0; // Boolean

    NodoA *nodo = padreMasIzq(parbol);
    while (nodo)
    {
        if (strcmp(nodo->simbolo, "BLOQ_EJEC") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdadero, contFalso, contOr);
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
            // Condicion simple
            if (ES_COMPARADOR(nodo->izq->simbolo) == 1)
            {
                generarComparacion(fp, nodo->izq, TAG_FALSO, contFalso);
                apilar(&falsos, &contFalso, sizeof(contFalso));
                contFalso++;
            }
            // Condicion multiple
            else if (ES_OP_LOGICO(nodo->izq->simbolo) == 1)
            {
                NodoA *opLogico = nodo->izq;

                if (strcmp(nodo->izq->simbolo, "&") == 0)
                {
                    // 1era condicion
                    fprintf(fp, "FLD %s\n", opLogico->izq->izq->simbolo);
                    fprintf(fp, "FCOMP %s\n", opLogico->izq->der->simbolo);
                    fprintf(fp, "FSTSW @ax\n"); // Los flags del coprocesador en memoria
                    fprintf(fp, "SAHF\n");      // Guardo los flags que estan en memoria en el registro FLAG del cpu
                    generarComparacion(fp, nodo->izq, TAG_FALSO, contFalso);

                    // 2da condicion
                    fprintf(fp, "FLD %s\n", opLogico->der->izq->simbolo);
                    fprintf(fp, "FCOMP %s\n", opLogico->der->der->simbolo);
                    fprintf(fp, "FSTSW @ax\n"); // Los flags del coprocesador en memoria
                    fprintf(fp, "SAHF\n");      // Guardo los flags que estan en memoria en el registro FLAG del cpu
                    generarComparacion(fp, nodo->der, TAG_FALSO, contFalso);

                    apilar(&falsos, &contFalso, sizeof(contFalso));
                    contFalso++;
                }
                else if (strcmp(nodo->izq->simbolo, "||") == 0)
                {
                    invertirCondicion(opLogico->izq);

                    fprintf(fp, "FLD %s\n", opLogico->izq->izq->simbolo);
                    fprintf(fp, "FCOMP %s\n", opLogico->izq->der->simbolo);
                    fprintf(fp, "FSTSW @ax\n"); // Los flags del coprocesador en memoria
                    fprintf(fp, "SAHF\n");      // Guardo los flags que estan en memoria en el registro FLAG del cpu
                    generarComparacion(fp, opLogico->izq, TAG_FALSO, contFalso);
                    contFalso++;

                    // 2da condicion
                    fprintf(fp, "FLD %s\n", opLogico->der->izq->simbolo);
                    fprintf(fp, "FCOMP %s\n", opLogico->der->der->simbolo);
                    fprintf(fp, "FSTSW @ax\n"); // Los flags del coprocesador en memoria
                    fprintf(fp, "SAHF\n");      // Guardo los flags que estan en memoria en el registro FLAG del cpu
                    generarComparacion(fp, opLogico->der->izq, TAG_OR, contOr);

                    // if (existeElse == 1)
                    // {
                    //     desapilar(&ifFalso, etiquetaFalso, sizeof(etiquetaFalso));
                    //     fprintf(fp, "%s\n", etiquetaFalso);
                    //     existeElse = 0;
                    // }

                    apilar(&ors, &contOr, sizeof(contOr));
                    contOr++;
                    operadorOr = TRUE;
                }
            }

            // if con else
            if (strcmp(nodo->der->simbolo, "CUERPO") == 0)
            {
                desapilar(&falsos, &numeroAuxiliar, sizeof(numeroAuxiliar));
                fprintf(fp, "%s%d\n", TAG_FALSO, numeroAuxiliar);

                if (operadorOr)
                {
                    // True
                    generarAssembler(&nodo->der->izq, fp, contAux, contVerdadero, contFalso, contOr);
                    contVerdadero++;
                    apilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
                    fprintf(fp, "BI %s%d\n", TAG_VERDADERO, contVerdadero);
                    desapilar(&ors, &contOr, sizeof(contOr));
                    fprintf(fp, "%s%d\n", TAG_OR, contOr);
                    // False
                    generarAssembler(&nodo->der->der, fp, contAux, contVerdadero, contFalso, contOr);
                    desapilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
                    fprintf(fp, "%s%d\n", TAG_VERDADERO, contVerdadero);

                    operadorOr = 0;
                }
                else
                {
                    // True
                    generarAssembler(&nodo->der->izq, fp, contAux, contVerdadero, contFalso, contOr);
                    contVerdadero++;
                    apilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
                    fprintf(fp, "BI %s%d\n", TAG_VERDADERO, contVerdadero);

                    desapilar(&falsos, &contFalso, sizeof(contFalso));
                    fprintf(fp, "%s%d\n", TAG_FALSO, contFalso);
                    // False
                    generarAssembler(&nodo->der->izq, fp, contAux, contVerdadero, contFalso, contOr);
                    desapilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
                    fprintf(fp, "%s%d\n", TAG_VERDADERO, contVerdadero);
                }
            }
            // if sin else
            else
            {
                if (operadorOr == 1)
                {
                    desapilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
                    fprintf(fp, "%s%d\n", TAG_VERDADERO, contVerdadero);
                    generarAssembler(&nodo->der, fp, contAux, contVerdadero, contFalso, contOr);
                    desapilar(&ors, &contOr, sizeof(contOr));
                    fprintf(fp, "%s%d\n", TAG_OR, contOr);
                    operadorOr = 0;
                }
                else
                {
                    generarAssembler(&nodo->der, fp, contAux, contVerdadero, contFalso, contOr);
                    desapilar(&falsos, &contFalso, sizeof(contFalso));
                    fprintf(fp, "%s%d\n", TAG_FALSO, contFalso);
                }
            }

            apilar(&falsos, &contFalso, sizeof(contFalso));
            contFalso++;
        }
        else if (strcmp(nodo->simbolo, "write") == 0)
        {
            fprintf(fp, "displayString %s\n", nodo->izq->simbolo);
        }
        else if (strcmp(nodo->simbolo, "read") == 0)
        {
            fprintf(fp, "getString %s\n", nodo->izq->simbolo);
        }

        eliminarHijos(nodo);
        nodo = padreMasIzq(parbol);
    }
}

void generarComparacion(FILE *fp, NodoA *comparador, char *tag, int cont)
{
    char *simbolo = comparador->simbolo;

    fprintf(fp, "FLD %s\n", comparador->izq->simbolo);
    fprintf(fp, "FCOMP %s\n", comparador->der->simbolo);
    fprintf(fp, "FSTSW @ax\n"); // Los flags del coprocesador en memoria
    fprintf(fp, "SAHF\n");      // Guardo los flags que estan en memoria en el registro FLAG del cpu

    if (strcmp(simbolo, "<") == 0)
    {
        fprintf(fp, "JNB %s%d\n", tag, cont);
    }
    else if (strcmp(simbolo, ">") == 0)
    {
        fprintf(fp, "JBE %s%d\n", tag, cont);
    }
    else if (strcmp(simbolo, "<=") == 0)
    {
        fprintf(fp, "JNBE %s%d\n", tag, cont);
    }
    else if (strcmp(simbolo, ">=") == 0)
    {
        fprintf(fp, "JNAE %s%d\n", tag, cont);
    }
    else if (strcmp(simbolo, "!=") == 0)
    {
        fprintf(fp, "JE %s%d\n", tag, cont);
    }
    else if (strcmp(simbolo, "==") == 0)
    {
        fprintf(fp, "JNE %s%d\n", tag, cont);
    }
}

void invertirCondicion(NodoA *padre)
{
    if (strcmp(padre->simbolo, "<") == 0)
    {
        strcpy(padre->simbolo, ">=");
    }
    else if (strcmp(padre->simbolo, ">") == 0)
    {
        strcpy(padre->simbolo, "<=");
    }
    else if (strcmp(padre->simbolo, "<=") == 0)
    {
        strcpy(padre->simbolo, ">");
    }
    else if (strcmp(padre->simbolo, ">=") == 0)
    {
        strcpy(padre->simbolo, "<");
    }
    else if (strcmp(padre->simbolo, "==") == 0)
    {
        strcpy(padre->simbolo, "!=");
    }
    else if (strcmp(padre->simbolo, "!=") == 0)
    {
        strcpy(padre->simbolo, "==");
    }
}