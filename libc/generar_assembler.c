#include "generar_assembler.h"

int contFalsos = 0;
int contVerdaderos = 0;
int contCiclos = 0;

void generarAssembler(Arbol *parbol, FILE *fp, int contAux)
{
    Pila ciclos = crearPila(&ciclos);
    Pila verdaderos = crearPila(&verdaderos);
    Pila falsos = crearPila(&falsos);
    char aux[VALOR_LARGO_MAX + 1];
    char auxOperando[VALOR_LARGO_MAX + 1];
    int numeroAuxiliar;

    NodoA *nodo = padreMasIzq(parbol);
    while (nodo)
    {
        if (strcmp(nodo->simbolo, "BLOQ_EJEC") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux);
            contAux = 0;
        }
        else if (strcmp(nodo->simbolo, "=") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux);
            fprintf(fp, "FLD %s\nFRNDINT\nFSTP %s\n", nodo->der->simbolo, nodo->izq->simbolo);
        }
        else if (strcmp(nodo->simbolo, "+") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux);
            fprintf(fp, "FLD %s\nFLD %s\nFADD\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "-") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux);
            fprintf(fp, "FLD %s\nFLD %s\nFSUB\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "*") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux);
            fprintf(fp, "FLD %s\nFLD %s\nFMUL\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "/") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux);
            fprintf(fp, "FLD %s\nFLD %s\nFDIV\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "if") == 0)
        {
            generarIf(fp, nodo, &verdaderos, &falsos, contAux);
        }
        else if (strcmp(nodo->simbolo, "ciclo") == 0)
        {
            fprintf(fp, "%s%d:\n", TAG_CICLO, contCiclos);
            apilar(&ciclos, &contCiclos, sizeof(contCiclos));
            contCiclos++;
            generarIf(fp, nodo, &verdaderos, &falsos, contAux);
            desapilar(&ciclos, &numeroAuxiliar, sizeof(numeroAuxiliar));
            fprintf(fp, "JMP %s%d\n", TAG_CICLO, numeroAuxiliar);
        }
        else if (strcmp(nodo->simbolo, "write") == 0)
        {

            if (esMismoTipo(&listaSimbolos, nodo->izq->simbolo, TSTRING))
            {
                fprintf(fp, "displayString %s\nnewLine 1\n", nodo->izq->simbolo);
            }
            else
            {
                fprintf(fp, "displayFloat %s\nnewLine 1\n", nodo->izq->simbolo);
            }
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
    fprintf(fp, "FSTSW AX\n"); // Los flags del coprocesador en memoria
    fprintf(fp, "SAHF\n");     // Guardo los flags que estan en memoria en el registro FLAG del cpu

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

void invertirComparador(NodoA *nodo)
{
    if (strcmp(nodo->simbolo, "<") == 0)
    {
        strcpy(nodo->simbolo, ">=");
    }
    else if (strcmp(nodo->simbolo, ">") == 0)
    {
        strcpy(nodo->simbolo, "<=");
    }
    else if (strcmp(nodo->simbolo, "<=") == 0)
    {
        strcpy(nodo->simbolo, ">");
    }
    else if (strcmp(nodo->simbolo, ">=") == 0)
    {
        strcpy(nodo->simbolo, "<");
    }
    else if (strcmp(nodo->simbolo, "==") == 0)
    {
        strcpy(nodo->simbolo, "!=");
    }
    else if (strcmp(nodo->simbolo, "!=") == 0)
    {
        strcpy(nodo->simbolo, "==");
    }
}

void generarIf(FILE *fp, NodoA *nodo, Pila *verdaderos, Pila *falsos, int contAux)
{
    int operadorOr = FALSE; // Boolean
    int numeroAuxiliar;

    // Condicion simple
    if (ES_COMPARADOR(nodo->izq->simbolo) == 1)
    {
        generarComparacion(fp, nodo->izq, TAG_FALSO, contFalsos);
        apilar(falsos, &contFalsos, sizeof(contFalsos));
        contFalsos++;
    }
    // Condicion multiple (o operador not)
    if (strcmp(nodo->izq->simbolo, "&") == 0 && strcmp(nodo->izq->izq->simbolo, "not") == 0)
    {
        invertirComparador(nodo->izq->der);
        generarComparacion(fp, nodo->izq->der, TAG_FALSO, contFalsos);
        apilar(falsos, &contFalsos, sizeof(contFalsos));
        contFalsos++;
    }
    else if (strcmp(nodo->izq->simbolo, "&") == 0)
    {
        // 1era condicion
        generarComparacion(fp, nodo->izq->izq, TAG_FALSO, contFalsos);
        // 2da condicion
        generarComparacion(fp, nodo->izq->der, TAG_FALSO, contFalsos);
        apilar(falsos, &contFalsos, sizeof(contFalsos));
        contFalsos++;
    }
    else if (strcmp(nodo->izq->simbolo, "||") == 0)
    {
        invertirComparador(nodo->izq->izq);
        // 1era condicion
        generarComparacion(fp, nodo->izq->izq, TAG_VERDADERO, contVerdaderos);
        apilar(verdaderos, &contVerdaderos, sizeof(contVerdaderos));
        contVerdaderos++;
        // 2da condicion
        generarComparacion(fp, nodo->izq->der, TAG_FALSO, contFalsos);
        apilar(falsos, &contFalsos, sizeof(contFalsos));
        contFalsos++;
        operadorOr = TRUE;
    }
    // if con else
    if (strcmp(nodo->der->simbolo, "CUERPO") == 0)
    {
        desapilar(falsos, &numeroAuxiliar, sizeof(numeroAuxiliar));
        fprintf(fp, "%s%d:\n", TAG_FALSO, numeroAuxiliar);

        if (operadorOr)
        {
            // True
            generarAssembler(&nodo->der->izq, fp, contAux);
            // apilar(verdaderos, &contVerdaderos, sizeof(contVerdaderos));
            // contVerdaderos++;
            fprintf(fp, "JMP %s%d\n", TAG_VERDADERO, contVerdaderos);
            desapilar(falsos, &contFalsos, sizeof(contFalsos));
            fprintf(fp, "%s%d:\n", TAG_FALSO, contFalsos);
            // False
            generarAssembler(&nodo->der->der, fp, contAux);
            desapilar(verdaderos, &contVerdaderos, sizeof(contVerdaderos));
            fprintf(fp, "%s%d:\n", TAG_VERDADERO, contVerdaderos);
            operadorOr = FALSE;
        }
        else
        {
            // True
            generarAssembler(&nodo->der->izq, fp, contAux);
            // apilar(verdaderos, &contVerdaderos, sizeof(contVerdaderos));
            // contVerdaderos++;
            fprintf(fp, "JMP %s%d\n", TAG_VERDADERO, contVerdaderos);
            desapilar(falsos, &contFalsos, sizeof(contFalsos));
            fprintf(fp, "%s%d:\n", TAG_FALSO, contFalsos);
            // False
            generarAssembler(&nodo->der->der, fp, contAux);
            desapilar(verdaderos, &contVerdaderos, sizeof(contVerdaderos));
            fprintf(fp, "%s%d:\n", TAG_VERDADERO, contVerdaderos);
        }
    }
    else
    {
        if (operadorOr)
        {
            desapilar(verdaderos, &contVerdaderos, sizeof(contVerdaderos));
            fprintf(fp, "%s%d:\n", TAG_VERDADERO, contVerdaderos);
            generarAssembler(&nodo->der, fp, contAux);
            desapilar(falsos, &contFalsos, sizeof(contFalsos));
            fprintf(fp, "%s%d:\n", TAG_FALSO, contFalsos);
            operadorOr = FALSE;
        }
        else
        {
            generarAssembler(&nodo->der, fp, contAux);
            desapilar(falsos, &contFalsos, sizeof(contFalsos));
            fprintf(fp, "%s%d:\n", TAG_FALSO, contFalsos);
        }
    }
    apilar(falsos, &contFalsos, sizeof(contFalsos));
    contFalsos++;
}

void generarFin(FILE *fp)
{
    fprintf(fp, "\n");
    fprintf(fp, "MOV AX, 4C00H\n");
    fprintf(fp, "INT 21h\n");
    fprintf(fp, "END START\n");
}