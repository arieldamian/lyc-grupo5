#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// START TABLA DE SIMBOLOS

#define T_CTE_INTEGER 1
#define T_CTE_STRING 2
#define T_FLOAT 3
#define T_ID 4

typedef struct {
	char nombre[50];
	int tipo;
	char dato[50];
	int longitud;
} t_simbolo;

void insertarTablaSimbolos(char *, int, char *, int);
void mostrarTablaSimbolos();
int tsCrearArchivo();

char * indicarNombreConstante(const char *);
char * obtenerNombreTipo(int);
// END TABLA DE SIMBOLOS

// START ASM

void generarAssembler();
int generarHeader();
int generarInstrucciones();
int generarData();
int generarFooter();
int ensamblar();
int unirArchivo(FILE *, char *, char *);

// END ASM

