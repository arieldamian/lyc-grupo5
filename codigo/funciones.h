#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// START TABLA DE SIMBOLOS

#define T_CTE_INTEGER 1
#define T_CTE_STRING 2
#define T_FLOAT 3
#define T_ID 4

#define MAS "+"
#define IGUAL "="
#define IGUAL_2 ":"
#define CMP "CMP"
#define SALTO_POR_DISTINTO "JNE"
#define SALTO_POR_MAYOR "BGT"
#define SALTO_POR_MAYOR_IGUAL "BGE"
#define SALTO_POR_MENOR_O_IGUAL "BLE"
#define SALTO_INCONDICIONAL "BI"
#define SALTO_IGUAL "BE"
#define SALTO_WHILE "ET"
#define LEER "GET"
#define ESCRIBIR "PUT"

typedef struct {
	int tag;
    int position;
    int isWhile;
} t_tag;

typedef struct {
	char nombre[50];
	int tipo;
	char dato[50];
	int longitud;
} t_simbolo;

typedef struct {
	int numeroEtiqueta;
	int posicionDeSalto;
} t_pila_retorno;

void insertarTablaSimbolos(char *, int, char *, int);
void mostrarTablaSimbolos();
int tsCrearArchivo();

char * indicarNombreConstante(const char *);
char * obtenerNombreTipo(int);
// END TABLA DE SIMBOLOS

// START ASM
int getTag(t_tag ts[],int position,int cant,int isWhile);
void generarAssembler();
int generarHeader();
int generarInstrucciones();
int generarData();
int generarFooter();
int ensamblar();
int unirArchivo(FILE *, char *, char *);

char * desapilarOperador();
void apilarOperador(char * );
void pedirAux(char *);
void pedirEtiqueta();

// END ASM

