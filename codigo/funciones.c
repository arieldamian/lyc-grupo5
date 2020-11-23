#include "funciones.h"

t_simbolo tablaSimbolos[100];
int posActualTablaSimbolos = 0;

// START TABLA DE SIMBOLOS
void insertarTablaSimbolos(char * nombre, int tipo, char * dato, int longitud) {
    int i;
    for (i = 0; i < posActualTablaSimbolos; i++)
		if (strcmp(tablaSimbolos[i].nombre, nombre) == 0)
			return;
	t_simbolo tmp;
	strcpy(tmp.nombre, nombre);
	tmp.tipo = tipo;
	strcpy(tmp.dato, dato);
	tmp.longitud = longitud;
	tablaSimbolos[posActualTablaSimbolos++] = tmp;
}

void mostrarTablaSimbolos() {
	int i;
	printf("Cantidad de simbolos en tabla: %d\n", posActualTablaSimbolos);
	for(i = 0; i < posActualTablaSimbolos ; i++) {
		printf("POS. %d, NOMBRE %s, TIPO %d, DATO %s, LONGITUD %d\n", i, tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
	}
}

char * indicarNombreConstante(const char * valor) {
	char nombre[100] = "_";
	strcat(nombre, valor);
	return strdup(nombre);
}

int tsCrearArchivo() {
	int i;
	FILE *archivo;

	archivo = fopen("ts.txt", "w");
	if (!archivo) {
		return 1;
	}

	// Cabecera del archivo
	fprintf(archivo, "%-32s%-13s%-31s%-12s\n", "Nombre", "Tipo", "Valor", "Longitud");

	// Se escribe linea por linea
	for (i = 0; i < posActualTablaSimbolos; i++) {
		if (tablaSimbolos[i].tipo == T_CTE_INTEGER || 
			tablaSimbolos[i].tipo == T_FLOAT ||
			tablaSimbolos[i].tipo == T_ID
		) {
			fprintf(archivo, "%-32s%-13s\n", tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo));
		} else {
			fprintf(archivo, "%-32s%-13s%-31s%-12s\n",
			indicarNombreConstante(tablaSimbolos[i].nombre), obtenerNombreTipo(tablaSimbolos[i].tipo), tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
		}
	}
	fclose(archivo);

	return 0;
}

char * obtenerNombreTipo(const int tipo) {
	switch(tipo) {
		case T_CTE_INTEGER:
			return "INTEGER";
		case T_CTE_STRING:
			return "STRING";
		case T_FLOAT:
			return "FLOAT";
		case T_ID:
			return "IDENTIFICADOR";
	}
}

// END TABLA DE SIMBOLOS

// START ASM

void generarAssembler() {
  if (generarHeader()) {
      printf("Error al generar el header\n");
      exit(1);
  }

  
  if (generarData()) {
    printf("Error al generar la data\n");
    exit(1);
	}
/*
  if (generarInstrucciones()) {
      printf("Error al generar las instrucciones\n");
      exit(1);
  }
  */

  if (generarFooter()) {
		printf("Error al generar el footer\n");
		exit(1);
	}

  if (ensamblar()) {
		printf("Error al ensamblar el archivo final\n");
		exit(1);
  }
}

int generarHeader() {
	FILE * fp = fopen("./assembler/header", "w");
	if (fp == NULL) {
		return 1;
	}

	fprintf(fp, "INCLUDE macros2.asm\n");
  fprintf(fp, "INCLUDE number.asm\n");
  fprintf(fp, ".MODEL LARGE\n");
  fprintf(fp, ".386\n");
  fprintf(fp, ".STACK 200h\n"); 
  fclose(fp);

  return 0;
}

int generarData() {
    FILE * fp = fopen("./assembler/data", "w");
	if (fp == NULL) {
		return 1;
	}

	fprintf(fp, "\t.DATA\n");    
  fprintf(fp, "\tTRUE equ 1\n");
  fprintf(fp, "\tFALSE equ 0\n");
  fprintf(fp, "\tMAXTEXTSIZE equ %d\n", 200);

  int i;
  for (i = 0; i < posActualTablaSimbolos; i++) {
    if (tablaSimbolos[i].tipo == T_CTE_STRING)
      fprintf(fp, "%-32s\tdb\t%s,'$', %d dup (?)\n", tablaSimbolos[i].nombre, tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
    else
      fprintf(fp, "%-32s\tdd\t%s\n", tablaSimbolos[i].nombre, tablaSimbolos[i].dato);
  }
  fprintf(fp, "\n.CODE\n");
  fprintf(fp, "START:\n");
  fprintf(fp, "MOV AX,@DATA\n");
  fprintf(fp, "MOV DS,AX\n");
  fprintf(fp, "MOV es,ax\n");
  fprintf(fp, "FINIT\n");
  fprintf(fp, "FFREE\n\n");
  fclose(fp);
  
  return 0;
}

int generarInstrucciones() {
  /*
    FILE * fp;
    
    fp = fopen("./assembler/instrucciones", "w");
    if (fp == NULL) {
        return 1;
    }

    char * op1;
    char * op2;
    int i;
    for (i = 0; i < getPosActualPolaca(); i++) {
        if (i == posicion) {
            posicion = -1;
            fprintf(fp, "%s:\n", etiqueta);
        }

        char * dato = polaca[i].dato;
        if (strcmp(dato, MAS) == 0) {
            op1 = desapilarOperador();
            op2 = desapilarOperador();
            fprintf(fp, "fild %s\n", op1);
            fprintf(fp, "fild %s\n", op2);
            fprintf(fp, "fadd\n");
            char aux[20];
            pedirAux(aux);
            fprintf(fp, "fistp %s\n", aux);
            apilarOperador(aux);
        } else if (strcmp(dato, IGUAL) == 0) {
            op1 = desapilarOperador();
            op2 = desapilarOperador();
            fprintf(fp, "fild %s\n", op2);
            fprintf(fp, "fistp %s\n", op1);
        } else if (strcmp(dato, CMP) == 0) {
            op1 = desapilarOperador();
            op2 = desapilarOperador();
            fprintf(fp, "fild %s\n", op1);
            fprintf(fp, "fild %s\n", op2);   
            fprintf(fp, "fcom\n");
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
        } else if (strcmp(dato, SALTO_POR_DISTINTO) == 0) {
            pedirEtiqueta();
            fprintf(fp, "JNE %s\n", etiqueta);
            esPosicion = 1;
        } else if (strcmp(dato, LEER) == 0) {
            esLectura = 1;
        } else if (strcmp(dato, ESCRIBIR) == 0) {
            esEscritura = 1;
        } else {
            if(esPosicion) {
                esPosicion = 0;
                posicion = atoi(dato);
            } else if(esEscritura) {
                esEscritura = 0;
                if(polaca[i].tipoDato == T_CTE_STRING || polaca[i].tipoDato == T_STRING)
                    fprintf(fp, "DisplayString %s\n", dato);
                else if(polaca[i].tipoDato == T_CTE_INTEGER || polaca[i].tipoDato == T_INTEGER || polaca[i].tipoDato == T_ID)
                    fprintf(fp, "DisplayInteger %s\n", dato);
                fprintf(fp, "newLine 1\n");
            } else if(esLectura) {
                esLectura = 0;
                fprintf(fp, "GetInteger %s\n", dato);
            }
            apilarOperador(dato);
        }
    }
    fclose(fp);*/
    return 0;
}

int generarFooter() {
    FILE * fp = fopen("./assembler/footer", "w");
	if (fp == NULL) {
		return 1;
	}
    fprintf(fp, "\tffree\n");
	fprintf(fp, "\tmov ax, 4c00h\n");
    fprintf(fp, "\tint 21h\n");
    fprintf(fp, "\tEnd START\n"); 
    fclose(fp);
    return 0;
}

int ensamblar() {
    FILE * fp = fopen("Final.asm", "w");
    char buffer[100];
    if (fp == NULL)	
		return 1;
    if(unirArchivo(fp, "./assembler/header", buffer) ||
    unirArchivo(fp, "./assembler/data", buffer) ||
    // unirArchivo(fp, "./assembler/instrucciones", buffer) ||
    unirArchivo(fp, "./assembler/footer", buffer))
		return 1;
    fclose(fp);
    return 0;
}

int unirArchivo(FILE * fp, char * nombre, char * buffer){
    FILE * file = fopen( nombre, "r");
	if (file == NULL) {
		printf("Error al abrir el archivo %s\n", nombre);
		return 1;
	}
    while(fgets(buffer, sizeof(buffer), file))
        fprintf(fp, "%s", buffer);
    fclose(file);
    remove(nombre);
    return 0;
}

// END ASM
