#define ID_LARGO_MAX 40
#define TIPO_DATO_LARGO_MAX 7
#define VALOR_LARGO_MAX 40
#define MAX_INT 32768
#define MIN_INT -32768
#define MAX_FLOAT 2147483648
#define MIN_FLOAT -2147483648

#define TRUE 1
#define FALSE 0

#define TINT "Int"
#define TFLOAT "Float"
#define TSTRING "String"

#define MIN(a, b) ((a < b) ? a : b)

#define FILENAME_TS "tabla_simbolos.txt"
#define FILENAME_DOT "intermedia.dot"
#define FILENAME_ASM "final.asm"

char *concatenar(char *str1, char *str2, int n);
int estaContenido(char *str1, char *str2);
char *manipularCadena(char *dest, char *str);
char *limpiarComillas(char *dest, char *ori);