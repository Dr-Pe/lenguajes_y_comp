#include <string.h>
#include "utilidades.h"

char *concatenar(char *str1, char *str2, int n)
{

    if (strlen(str1) <= n + 2 || strlen(str2) <= n + 2)
    { //+2 por ""
        return "ERROR";
    }

    char aux[strlen(str1) + strlen(str2) + 3]; // si n=0
    aux[0] = '"';

    strcpy(aux + 1, str1 + n + 1);
    strcpy(aux + strlen(aux) - 1, str2 + n + 1);
    strcpy(str1, aux);

    if (strlen(str1) >= VALOR_LARGO_MAX + 3)
    {
        return "ERROR";
    }

    return str1;
}

int estaContenido(char *str1, char *str2)
{
    char strAux[VALOR_LARGO_MAX + 2];
    char strAux2[VALOR_LARGO_MAX + 2];

    return strstr(
               cadenaANombre(strAux, str1),
               cadenaANombre(strAux2, str2)) != NULL ||
           strstr(
               cadenaANombre(strAux2, str2),
               cadenaANombre(strAux, str1)) != NULL;
}

char *cadenaANombre(char *dest, char *str)
{
    char strAux[VALOR_LARGO_MAX + 2];

    strcpy(dest, "_");
    strcat(dest, limpiarComillas(strAux, str));

    int i;
    for (i = 0; i < strlen(dest); i++)
    {
        if (!ES_LETRA(dest[i]) && !ES_DIGITO(dest[i]))
        {
            dest[i] = '_';
        }
    }

    return dest;
}

char *floatANombre(char *dest)
{
    char strAux[VALOR_LARGO_MAX + 2];

    strAux[0] = '_';
    strAux[1] = '\0';
    strcat(strAux, dest);
    strcpy(dest, strAux);

    int i;
    for (i = 1; i < strlen(dest); i++)
    {
        if (!ES_LETRA(dest[i]) && !ES_DIGITO(dest[i]))
        {
            dest[i] = '_';
        }
    }

    return dest;
}

char *limpiarComillas(char *destino, char *origen)
{
    int len = strlen(origen);
    strncpy(destino, origen + 1, len - 2);
    destino[len - 2] = '\0';
    return destino;
}