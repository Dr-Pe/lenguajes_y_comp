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
#define ES_LETRA(c) ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))
#define ES_DIGITO(c) (c >= '0' && c <= '9')

#define FILENAME_TS "symbol-table.txt"
#define FILENAME_DOT "intermediate-code.dot"
#define FILENAME_ASM "assm/final.asm"

char *concatenar(char *str1, char *str2, int n);
int estaContenido(char *str1, char *str2);
char *cadenaANombre(char *dest, char *str);
char *floatANombre(char *dest);
char *limpiarComillas(char *dest, char *ori);