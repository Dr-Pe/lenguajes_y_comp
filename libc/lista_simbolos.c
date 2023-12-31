#include "lista_simbolos.h"

Lista listaSimbolos;

Lista crearLista(Lista *pl)
{
    *pl = NULL;
    return *pl;
}

void insertarEnLista(Lista *lista, char *nombre, enum tiposDato tDato)
{
    Simbolo nuevo_simbolo;

    nuevo_simbolo.valor[0] = '\0';
    nuevo_simbolo.tipo_dato[0] = '\0';
    nuevo_simbolo.longitud = 0;

    if (tDato == tID)
    {
        strcpy(nuevo_simbolo.nombre, nombre);
    }
    else if (tDato == tINT)
    {
        strcpy(nuevo_simbolo.nombre, "_");
        strcat(nuevo_simbolo.nombre, nombre);
        strcpy(nuevo_simbolo.tipo_dato, TINT);
        strcpy(nuevo_simbolo.valor, nombre);
        nuevo_simbolo.longitud = strlen(nombre);
    }
    else if (tDato == tFLOAT)
    {
        char nnombre[strlen(nombre)];
        snprintf(nnombre, VALOR_LARGO_MAX + 1, "%.2f", atof(nombre));
        strcpy(nuevo_simbolo.nombre, floatANombre(nnombre));
        strcpy(nuevo_simbolo.tipo_dato, TFLOAT);
        strcpy(nuevo_simbolo.valor, nombre);
        nuevo_simbolo.longitud = strlen(nombre);
    }
    else if (tDato == tSTRING)
    {
        // char aux[] = "\"\"";
        // No guarda string vacios
        // if (strcmp(nombre, aux) == 0)
        // {
        //     return;
        // }
        int longitud = strlen(nombre) - 2; // -1 para sacar\0 -1 para "
        char valor[longitud - 2];
        char nnombre[longitud - 1];
        strcpy(nuevo_simbolo.nombre, cadenaANombre(nnombre, nombre));
        strcpy(nuevo_simbolo.tipo_dato, TSTRING);
        strcpy(nuevo_simbolo.valor, limpiarComillas(valor, nombre));
        nuevo_simbolo.longitud = longitud;
    }

    while ((*lista != NULL) && strcmp((*lista)->simb.nombre, nuevo_simbolo.nombre) > 0)
    {
        lista = &(*lista)->sig;
    }

    if (*lista != NULL && tDato == tID && strcmp((*lista)->simb.nombre, nuevo_simbolo.nombre) == 0)
    {
        return;
    }
    else if (*lista != NULL && strcmp((*lista)->simb.nombre, nuevo_simbolo.nombre) == 0 && strcmp((*lista)->simb.tipo_dato, nuevo_simbolo.tipo_dato) == 0)
    {
        return;
    }

    NodoL *nuevo = (NodoL *)malloc(sizeof(NodoL));
    memcpy(&(nuevo->simb), &nuevo_simbolo, sizeof(Simbolo));
    nuevo->sig = *lista;
    *lista = nuevo;
}

void insertarAuxiliarEnLista(Lista* lista, char* nombre)
{
    Simbolo nuevo_simbolo;

    nuevo_simbolo.valor[0] = '\0';
    nuevo_simbolo.tipo_dato[0] = '\0';
    nuevo_simbolo.longitud = 0;

    strcpy(nuevo_simbolo.nombre, nombre);
    strcpy(nuevo_simbolo.tipo_dato, TFLOAT);

    while ((*lista != NULL) && strcmp((*lista)->simb.nombre, nuevo_simbolo.nombre) > 0)
    {
        lista = &(*lista)->sig;
    }

    if (*lista != NULL && strcmp((*lista)->simb.nombre, nuevo_simbolo.nombre) == 0)
    {
        return;
    }
    else if (*lista != NULL && strcmp((*lista)->simb.nombre, nuevo_simbolo.nombre) == 0 && strcmp((*lista)->simb.tipo_dato, nuevo_simbolo.tipo_dato) == 0)
    {
        return;
    }

    NodoL *nuevo = (NodoL *)malloc(sizeof(NodoL));
    memcpy(&(nuevo->simb), &nuevo_simbolo, sizeof(Simbolo));
    nuevo->sig = *lista;
    *lista = nuevo;
}

void imprimirLista(Lista *lista)
{
    FILE *fp = fopen(FILENAME_TS, "w");
    if (fp == NULL)
    {
        printf("Error al abrir el archivo\n");
        return;
    }
    fprintf(fp, "%-50s|%-7s|%-50s|%-10s\n", "nombre", "tipoDato", "valor", "longitud");
    while (*lista != NULL)
    {
        fprintf(fp, "%-50s|%-7s|%-50s|%-10d\n", (*lista)->simb.nombre, (*lista)->simb.tipo_dato, (*lista)->simb.valor, (*lista)->simb.longitud);
        lista = &(*lista)->sig;
    }

    fclose(fp);
}

int idDeclarado(Lista *lista, char *id)
{

    while ((*lista != NULL) && strcmp((*lista)->simb.nombre, id) > 0)
    {
        lista = &(*lista)->sig;
    }
    if (*lista != NULL && strcmp((*lista)->simb.nombre, id) == 0 && !strlen((*lista)->simb.tipo_dato))
    {
        return FALSE;
    }

    return TRUE;
}

void asignarTipoDato(Lista *lista, char *id, char *tipoDato)
{

    while ((*lista != NULL) && strcmp((*lista)->simb.nombre, id) > 0)
    {
        lista = &(*lista)->sig;
    }
    if (*lista != NULL && strcmp((*lista)->simb.nombre, id) == 0)
    {
        strcpy((*lista)->simb.tipo_dato, tipoDato);
    }
}

void vaciarLista(Lista *pl)
{
    NodoL *aux;

    while (*pl)
    {
        aux = *pl;
        *pl = (aux)->sig;
        free(aux);
    }
}

void asignarTipo(Lista *lista, char *auxTipo)
{
    while ((*lista != NULL))
    {
        strcpy((*lista)->simb.tipo_dato, auxTipo);
        lista = &(*lista)->sig;
    }
}

void fusionarLista(Lista *lista1, Lista *lista2)
{
    while ((*lista2 != NULL && *lista1 != NULL))
    {
        if (strcmp((*lista1)->simb.nombre, (*lista2)->simb.nombre) == 0)
        {
            strcpy((*lista1)->simb.tipo_dato, (*lista2)->simb.tipo_dato);
            lista2 = &(*lista2)->sig;
        }
        lista1 = &(*lista1)->sig;
    }
}

int esMismoTipo(Lista *lista, char *id, char *auxTipo)
{
    while ((*lista != NULL) && strcmp((*lista)->simb.nombre, id) > 0)
    {
        lista = &(*lista)->sig;
    }
    if (*lista != NULL && strcmp((*lista)->simb.nombre, id) == 0)
    {
        if (strcmp((*lista)->simb.tipo_dato, auxTipo) == 0)
        {
            return TRUE;
        }
    }
    return FALSE;
}

char *obtenerTipo(Lista *lista, char *id)
{
    while (*lista && strcmp((*lista)->simb.nombre, id) > 0)
    {
        lista = &(*lista)->sig;
    }
    if (*lista && strcmp((*lista)->simb.nombre, id) == 0)
    {
        return (*lista)->simb.tipo_dato;
    }
    return NULL;
}

void generarEncabezado(FILE *fp, Lista *lista, int cantAux)
{
    fprintf(fp, "INCLUDE number.asm\nINCLUDE macros.asm\n\n.MODEL LARGE\n.386\n.STACK 200h\n\n.DATA\n");
    while (*lista != NULL)
    {
        if (strlen((*lista)->simb.valor) == 0)
        {
            // Si es ID
            if (strcmp((*lista)->simb.tipo_dato, "String") == 0)
            {
                fprintf(fp, "%s db ?\n", (*lista)->simb.nombre);
            }
            else
            {
                fprintf(fp, "%s dd ?\n", (*lista)->simb.nombre);
            }
        }
        else if (strcmp((*lista)->simb.tipo_dato, "Int") == 0)
        {
            fprintf(fp, "%s dd %s.0\n", (*lista)->simb.nombre, (*lista)->simb.valor);
        }
        else if (strcmp((*lista)->simb.tipo_dato, "Float") == 0)
        {
            fprintf(fp, "%s dd %s\n", (*lista)->simb.nombre, (*lista)->simb.valor); // Si es float
        }
        else
        {
            fprintf(fp, "%s db \"%s\" , '$', %d dup (?)\n", (*lista)->simb.nombre, (*lista)->simb.valor, (*lista)->simb.longitud);
        }
        lista = &(*lista)->sig;
    }
    int i = 0;
    while (cantAux > 1)
    {
        fprintf(fp, "@aux%d dd ?\n", i);
        i++;
        cantAux--;
    }

    fprintf(fp, "\n");
    fprintf(fp, ".CODE\n\nSTART:\nmov AX, @DATA\nmov DS, AX\nmov ES, AX\n\n"); // Inicio de las lineas de codigo.
}