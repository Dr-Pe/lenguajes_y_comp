#include "generar_assembler.h"

void generarAssembler(Arbol *parbol, FILE *fp, int contAux, int contVerdaderos, int contFalsos, int contOr, int contCiclos)
{
    Pila ciclos = crearPila(&ciclos);
    char aux[VALOR_LARGO_MAX + 1];
    char auxOperando[VALOR_LARGO_MAX + 1];
    int numeroAuxiliar;

    NodoA *nodo = padreMasIzq(parbol);
    while (nodo)
    {
        if (strcmp(nodo->simbolo, "BLOQ_EJEC") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
            contAux = 0;
        }
        else if (strcmp(nodo->simbolo, "=") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
            fprintf(fp, "FLD %s\nFRNDINT\nFSTP %s\n", nodo->der->simbolo, nodo->izq->simbolo);
        }
        else if (strcmp(nodo->simbolo, "+") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
            fprintf(fp, "FLD %s\nFLD %s\nFADD\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "-") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
            fprintf(fp, "FLD %s\nFLD %s\nFSUB\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "*") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
            fprintf(fp, "FLD %s\nFLD %s\nFMUL\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "/") == 0)
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
            fprintf(fp, "FLD %s\nFLD %s\nFDIV\nFSTP @aux%d\n", nodo->izq->simbolo, nodo->der->simbolo, contAux);
            strcpy(aux, "@aux");
            snprintf(auxOperando, sizeof(contAux), "%d", contAux);
            strcat(aux, auxOperando);
            strcpy(nodo->simbolo, aux);
            contAux++;
        }
        else if (strcmp(nodo->simbolo, "if") == 0)
        {
            generarIf(fp, nodo, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
        }
        else if (strcmp(nodo->simbolo, "ciclo") == 0)
        {
            fprintf(fp, "%s%d\n", TAG_CICLO, contCiclos);
            apilar(&ciclos, &contCiclos, sizeof(contCiclos));
            contCiclos++;
            generarIf(fp, nodo, contAux, contVerdaderos, contFalsos, contOr, contCiclos);
            desapilar(&ciclos, &numeroAuxiliar, sizeof(numeroAuxiliar));
            fprintf(fp, "JMP %s%d\n", TAG_CICLO, numeroAuxiliar);
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

void invertirComparador(NodoA *nodo)
{
    printf("%s", nodo->simbolo);
    puts("AAAA");
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

void generarIf(FILE *fp, NodoA *nodo, int contAux, int contVerdadero, int contFalsos, int contOr, int contCiclos)
{
    Pila verdaderos = crearPila(&verdaderos);
    Pila falsos = crearPila(&falsos);
    Pila ors = crearPila(&ors);
    int operadorOr = FALSE; // Boolean
    int numeroAuxiliar;

    // Condicion simple
    if (ES_COMPARADOR(nodo->izq->simbolo) == 1)
    {
        generarComparacion(fp, nodo->izq, TAG_FALSO, contFalsos);
        apilar(&falsos, &contFalsos, sizeof(contFalsos));
        contFalsos++;
    }
    // Condicion multiple
    if (strcmp(nodo->izq->simbolo, "&") == 0)
    {
        // 1era condicion
        generarComparacion(fp, nodo->izq->izq, TAG_FALSO, contFalsos);
        // 2da condicion
        generarComparacion(fp, nodo->izq->der, TAG_FALSO, contFalsos);

        apilar(&falsos, &contFalsos, sizeof(contFalsos));
        contFalsos++;
    }
    else if (strcmp(nodo->izq->simbolo, "||") == 0)
    {
        printf("%s", nodo->izq->izq->simbolo);
        puts("AAAA");
        invertirComparador(nodo->izq->izq);
        // 1era condicion
        generarComparacion(fp, nodo->izq->izq, TAG_FALSO, contFalsos);
        contFalsos++;
        // 2da condicion
        generarComparacion(fp, nodo->izq->der, TAG_OR, contOr);

        apilar(&ors, &contOr, sizeof(contOr));
        contOr++;
        operadorOr = TRUE;
    }
    // if con else
    if (strcmp(nodo->der->simbolo, "CUERPO") == 0)
    {
        desapilar(&falsos, &numeroAuxiliar, sizeof(numeroAuxiliar));
        fprintf(fp, "%s%d\n", TAG_FALSO, numeroAuxiliar);

        if (operadorOr)
        {
            // True
            generarAssembler(&nodo->der->izq, fp, contAux, contVerdadero, contFalsos, contOr, contCiclos);
            contVerdadero++;
            apilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
            fprintf(fp, "JMP %s%d\n", TAG_VERDADERO, contVerdadero);
            desapilar(&ors, &contOr, sizeof(contOr));
            fprintf(fp, "%s%d\n", TAG_OR, contOr);
            // False
            generarAssembler(&nodo->der->der, fp, contAux, contVerdadero, contFalsos, contOr, contCiclos);
            desapilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
            fprintf(fp, "%s%d\n", TAG_VERDADERO, contVerdadero);

            operadorOr = FALSE;
        }
        else
        {
            // True
            generarAssembler(&nodo->der->izq, fp, contAux, contVerdadero, contFalsos, contOr, contCiclos);
            contVerdadero++;
            apilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
            fprintf(fp, "JMP %s%d\n", TAG_VERDADERO, contVerdadero);
            desapilar(&falsos, &contFalsos, sizeof(contFalsos));
            fprintf(fp, "%s%d\n", TAG_FALSO, contFalsos);
            // False
            generarAssembler(&nodo->der->der, fp, contAux, contVerdadero, contFalsos, contOr, contCiclos);
            desapilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
            fprintf(fp, "%s%d\n", TAG_VERDADERO, contVerdadero);
        }
    }
    else
    {
        if (operadorOr)
        {
            desapilar(&verdaderos, &contVerdadero, sizeof(contVerdadero));
            fprintf(fp, "%s%d\n", TAG_VERDADERO, contVerdadero);
            generarAssembler(&nodo->der, fp, contAux, contVerdadero, contFalsos, contOr, contCiclos);
            desapilar(&ors, &contOr, sizeof(contOr));
            fprintf(fp, "%s%d\n", TAG_OR, contOr);
            operadorOr = FALSE;
        }
        else
        {
            generarAssembler(&nodo->der, fp, contAux, contVerdadero, contFalsos, contOr, contCiclos);
            desapilar(&falsos, &contFalsos, sizeof(contFalsos));
            fprintf(fp, "%s%d\n", TAG_FALSO, contFalsos);
        }
    }
    apilar(&falsos, &contFalsos, sizeof(contFalsos));
    contFalsos++;
}

void generarFin(FILE *fp)
{
    fprintf(fp, "\n");
    fprintf(fp, "MOV EAX, 4C00H\n");
    fprintf(fp, "INT 21h\n");
    fprintf(fp, "END\n");
    fprintf(fp, ";");
}