#include "funciones.h"

t_simbolo tablaSimbolos[100];
int posActualTablaSimbolos = 0;

char polaquita [200][50];
int contadorPolaquita = 0;

int numeroAuxiliar = 0;

char etiqueta[20];
int numeroEtiqueta = 1;
int esPosicion = 0;
int posicion = -1;
int esEscritura = 0;
int esLectura = 0;
int pedir = 1;
// t_pila_retorno pilaPosicionRetornoCondicional[50];
int pilaPosicionRetornoCondicional[50];
int posActualPilaRetornoCondicional = 0;

int pilaPosiciones[100];
int posActualPilaPosiciones = 0;

char * pilaOperandos[100];
int posActualPilaOperandos = 0;

int flagWhile = 0;
int contCMP = 0;
int isElse = 0;
int indiceString = 0;

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

char *strrmc(char *str, char ch){
    char *from, *to;
    from = to = str;
    while(*from){
        if(*from == ch)
            ++from;
        else
            *to++ = *from++;
    }
    *to = '\0';
    return str;
}

char * indicarNombreConstante(const char * valor) {
	char nombre[100] = "_";
	strcat(nombre, valor);
	return strdup(nombre);
}

char * indicarNombreConstanteString(const char * valor) {
	char nombre[100];
    sprintf(nombre, "_cteString%d", indiceString++);
	return strdup(nombre);
}

int chuparPolaca() {
    // levanta polaca
    FILE * archivo;
    archivo = fopen("intermedia.txt", "rt");

    if (!archivo) {
		return 1;
	}

    while (fgets(polaquita[contadorPolaquita], sizeof(polaquita[contadorPolaquita]), archivo)) {
      if(!strchr(polaquita[contadorPolaquita],'\n')){
          printf("Reg. Invalido. \n %s",polaquita[contadorPolaquita]);
          exit(1);
      }

      contadorPolaquita++;
    }
    fclose(archivo);

    return 0;
}

int tsCrearArchivo() {
	int i;
	FILE *archivo;

	archivo = fopen("ts.txt", "w");
	if (!archivo) {
		return 1;
	}

	// Cabecera del archivo
	fprintf(archivo, "%-32s%-13s%-32s%-12s\n", "Nombre", "Tipo", "Valor", "Longitud");

	// Se escribe linea por linea
	for (i = 0; i < posActualTablaSimbolos; i++) {
		if (tablaSimbolos[i].tipo == T_CTE_INTEGER || 
			tablaSimbolos[i].tipo == T_FLOAT ||
			tablaSimbolos[i].tipo == T_ID
		) {
			fprintf(archivo, "%-32s%-13s\n", tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo));
		} else {
			fprintf(archivo, "%-32s%-13s%-32s%-12d\n",
			tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo), tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
		}
	}
	fclose(archivo);

	return 0;
}

int obtenerTipoDeDato(int posicionPolaquita) {
  if (polaquita[posicionPolaquita][0] == '_') {
    return T_CTE_STRING;
  } else if (isNumber(polaquita[posicionPolaquita])){
      if (isFloat(polaquita[posicionPolaquita])) {
          return T_FLOAT;
      }
      return T_CTE_INTEGER;
  }

  return T_ID;
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
        default:
            return "";
	}
}

// END TABLA DE SIMBOLOS

// START ASM
void generarAssembler() {
  if (generarHeader()) {
      printf("Error al generar el header\n");
      exit(1);
  }

  if (generarInstrucciones()) {
      printf("Error al generar las instrucciones\n");
      exit(1);
  }

  if (generarData()) {
    printf("Error al generar la data\n");
    exit(1);
  }

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
  int cteString = 1;
  char cte[33]; 
  for (i = 0; i < posActualTablaSimbolos; i++) {
    if (tablaSimbolos[i].tipo == T_CTE_STRING){
      fprintf(fp, "%-32s\tdb\t%s,'$', %d dup (?)\n", tablaSimbolos[i].nombre, tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
    } else {
        if(tablaSimbolos[i].tipo == T_CTE_INTEGER && tablaSimbolos[i].nombre[0] != '@' ){
            sprintf(cte, "%s", strrmc(tablaSimbolos[i].nombre, '.'));
            fprintf(fp, "%-32s\tdd\t%s.0\n", cte, tablaSimbolos[i].dato);
        } else {
            sprintf(cte, "%s", strrmc(tablaSimbolos[i].nombre, '.'));
            fprintf(fp, "%-32s\tdd\t%s\n", cte, tablaSimbolos[i].dato);
        }
    }
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
    FILE * fp;

    if(chuparPolaca()) {
        return 1;
    }
    
    fp = fopen("./assembler/instrucciones", "w");
    if (fp == NULL) {
        return 1;
    }
    
    t_tag tAux;
    t_aux auxs[200];
    int cantAux = 0;
    t_tag ts[200];
    int cant = 0;
    char * op1;
    char * op2;
    int i;
    for (i = 0; i < contadorPolaquita; i++) {
        int findTag = getTag(ts, i ,cant, flagWhile);
        if (findTag >= 0) {
            int tagFound = isPositionTag(ts,i,cant,&tAux);
            if(tagFound && !tAux.isWhile){
                fprintf(fp, "etiqueta%d:\n", tAux.tag);
            }
        }

        char * dato = polaquita[i];
        dato[strlen(dato) - 1] = '\0';
        if (dato[0] == '@') {
            char aux[20];
            int found = getAux(auxs, cantAux, dato, aux);
            if (!found){
                pedirAux(aux);
                strcpy(auxs[cantAux].name, dato);
                strcpy(auxs[cantAux].auxName, aux);
                printf("\n");
                printf("****** %s -- %s ******\n", dato, aux);
                cantAux++;
            }
            strcpy(dato, aux);
        } 
        if (strcmp(dato, MAS) == 0) {
            char auxOperador[20];

            op1 = desapilarOperador();
            op2 = desapilarOperador();

            if (isNumber(op1) || isFloat(op1)) {
                sprintf(auxOperador, "_%s", strrmc(op1, '.'));
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op1);
            }
            
            if (isNumber(op2) || isFloat(op2)) {
                sprintf(auxOperador, "_%s",  strrmc(op2, '.'));    
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op2);
            }
            
            fprintf(fp, "fadd\n");
            char aux[20];
            pedirAux(aux);
            fprintf(fp, "fstp %s\n", aux);
            apilarOperador(aux);
        } else if (strcmp(dato, DIVIDIDO) == 0) {
            char auxOperador[20];
            op1 = desapilarOperador();
            op2 = desapilarOperador();
            if (isNumber(op1) || isFloat(op1)) {
                sprintf(auxOperador, "_%s",  strrmc(op1, '.'));    
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op1);
            }
            
            if (isNumber(op2) || isFloat(op2)) {
                sprintf(auxOperador, "_%s",  strrmc(op2, '.'));    
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op2);
            }
            
            fprintf(fp, "fdiv\n");
            char aux[20];
            pedirAux(aux);
            fprintf(fp, "fstp %s\n", aux);
            apilarOperador(aux);
         } else if (strcmp(dato, MULTIPLICACION) == 0) {
            char auxOperador[20];
            op1 = desapilarOperador();
            op2 = desapilarOperador();
            if (isNumber(op1) || isFloat(op1)) {
                sprintf(auxOperador, "_%s", strrmc(op1, '.'));
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op1);
            }
            
            if (isNumber(op2) || isFloat(op2)) {
                sprintf(auxOperador, "_%s",  strrmc(op2, '.'));    
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op2);
            }
            
            fprintf(fp, "fmul\n");
            char aux[20];
            pedirAux(aux);
            fprintf(fp, "fstp %s\n", aux);
            apilarOperador(aux);
        } else if (strcmp(dato, IGUAL) == 0 || strcmp(dato, IGUAL_2) == 0) {
            op1 = desapilarOperador();
            op2 = desapilarOperador();
            char auxOperador[20];
        
            if (isNumber(op1)){
                if (isNumber(op1) || isFloat(op1)) {
                    sprintf(auxOperador, "_%s", strrmc(op1, '.'));
                    fprintf(fp, "fld %s\n", auxOperador);
                } else {
                    fprintf(fp, "fld %s\n", op1);
                }
                
                fprintf(fp, "fstp %s\n", op2);
            } else {
                if (isNumber(op2) || isFloat(op2)) {
                    sprintf(auxOperador, "_%s",  strrmc(op2, '.'));    
                    fprintf(fp, "fld %s\n", auxOperador);
                } else {
                    fprintf(fp, "fld %s\n", op2);
                }

                fprintf(fp, "fstp %s\n", op1);
            }
        } else if (strcmp(dato, CMP) == 0) {
            char auxOperador[20];
            
            op1 = desapilarOperador();
            op2 = desapilarOperador();
            if (isNumber(op1) || isFloat(op1)) {
                sprintf(auxOperador, "_%s",  strrmc(op1, '.'));    
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op1);
            }

            if (isNumber(op2) || isFloat(op2)) {
                sprintf(auxOperador, "_%s",  strrmc(op2, '.'));    
                fprintf(fp, "fld %s\n", auxOperador);
            } else {
                fprintf(fp, "fld %s\n", op2);
            }
            
            fprintf(fp, "fcom\n");
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
            contCMP++;
        } else if (strcmp(dato, SALTO_POR_DISTINTO) == 0) {
            // if (contCMP <= 1) {
                pedirEtiqueta();
                ts[cant].tag = numeroEtiqueta-1;
            // }
            fprintf(fp, "JNE %s\n", etiqueta);
            esPosicion = 1;
        } else if (strcmp(dato, SALTO_POR_MAYOR_IGUAL) == 0) {
            // **hacky** porque si no pide el if adentro del else etiqueta
            // cuando no deberia. Hack111
            /*if (contCMP <= 1) {
                pedirEtiqueta();
                ts[cant].tag = numeroEtiqueta-1;
            }*/
            fprintf(fp, "JAE %s\n", etiqueta);
            esPosicion = 1;
            pedir = 0;
        } else if (strcmp(dato, SALTO_POR_MAYOR) == 0) {
            if (contCMP <= 1) {
                pedirEtiqueta();
                ts[cant].tag = numeroEtiqueta-1;
            }
            fprintf(fp, "JA %s\n", etiqueta);
            esPosicion = 1;
        } else if (strcmp(dato, SALTO_IGUAL) == 0) {
            if (contCMP <= 1) {
                pedirEtiqueta();
                ts[cant].tag = numeroEtiqueta-1;
            }
            fprintf(fp, "JE %s\n", etiqueta);
            esPosicion = 1;
        } else if (strcmp(dato, SALTO_POR_MENOR_O_IGUAL) == 0) {
            if (contCMP <= 1) {
                pedirEtiqueta();
                ts[cant].tag = numeroEtiqueta-1;
            }
            fprintf(fp, "JNA %s\n", etiqueta);
            esPosicion = 1;
        } else if (strcmp(dato, SALTO_INCONDICIONAL) == 0) {
            if (!flagWhile) {
                pedirEtiqueta();
                fprintf(fp, "JMP %s\n", etiqueta);
            } else {
                int tag = getTag(ts,0,cant,flagWhile);
                fprintf(fp, "JMP etiqueta%d\n", tag);
                // fprintf(fp, "%s:\n", etiqueta);
                flagWhile = 0;
            }
            contCMP = 0;
        } else if (strcmp(dato, SALTO_WHILE) == 0) {
            pedirEtiqueta();
            fprintf(fp, "%s:\n", etiqueta);
            esPosicion = 1;
            ts[cant].tag = numeroEtiqueta - 1;
            ts[cant].position = i;
            ts[cant].isWhile = 1;
            flagWhile = 1;
            esPosicion = 0;
            cant++; 
        } else if (strcmp(dato, LEER) == 0) {
            esLectura = 1;
        } else if (strcmp(dato, ESCRIBIR) == 0) {
            esEscritura = 1;
        } else {
            if(esPosicion) {
                esPosicion = 0;
                posicion = atoi(dato) + 1;
                ts[cant].position = posicion;
                ts[cant].isWhile = 0;
                cant++;
            } else if(esEscritura) {
                esEscritura = 0;
                int indexTipoDato = obtenerTipoDeDato(i);
                if(indexTipoDato == T_CTE_STRING)
                    fprintf(fp, "DisplayString %s\n", dato);
                else {
                    fprintf(fp, "DisplayFloat %s, 2\n", dato);
                }
                fprintf(fp, "newLine 1\n");
            } else if(esLectura) {
                esLectura = 0;
                fprintf(fp, "GetFloat %s\n", dato);   
            } else {
                apilarOperador(dato);
            }
        }
    }
    fprintf(fp, "%s:\n", etiqueta); 
    fclose(fp);
  
    return 0;
}

int getTag(t_tag ts[],int position,int cant,int isWhile) {
    int i = 0;
    int found = -1;
    if(!isWhile){
        while(i < cant){
         if(ts[i].position == position){
            found = 1;
            break;
         }
         i++;
        }
    }else{
        for(i=cant;i>=0;i--){
            if(ts[i].isWhile == 1) {
                found = 1;
                break;
            }
        }
    }
    if (found == -1) {
        return -1;
    }
    return ts[i].tag; 
}

int isPositionTag(t_tag ts[],int position,int cant, t_tag* tAux) {
    int i = 0;
    int found = 0; 
    while(i < cant){
        if(ts[i].position == position) {
            found = 1;
            break;
        }
        i++;
    }
    tAux->isWhile = ts[i].isWhile;
    tAux->position = ts[i].position;
    tAux->tag = ts[i].tag;
    return found; 
}

int getAux(t_aux auxs[], int cant, char * name , char * var ) {
    int i = 0;
    int found = 0;
    while(i < cant){
        if(strcmp(auxs[i].name,name) == 0){
            found = 1;
            strcpy(var,auxs[i].auxName);
            break;
        }
        i++;
    }
    return found;
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
    unirArchivo(fp, "./assembler/instrucciones", buffer) ||
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

void pedirAux(char * aux) {
    sprintf(aux, "@aux%d", numeroAuxiliar++);
    insertarTablaSimbolos(aux, T_CTE_INTEGER, "?", 0);
}

void pedirEtiqueta() {
    if(pedir == 1)
    sprintf(etiqueta, "etiqueta%d", numeroEtiqueta++);
}

void apilarOperador(char * op) {
	pilaOperandos[posActualPilaOperandos++] = op;
} 

char * desapilarOperador() {
	return pilaOperandos[--posActualPilaOperandos];
}

int isNumber(char* s){
    int i = 0;
    while(s[i] != '\0') {
        if (!isnumber(s[i])) {
            return 0;
        }
        i++;
    }
    return 1;
}

int isFloat(char* s){
    int flag = 0;
    int i = 0;
    while(s[i++] != '\0') {
        if(s[i] == '.') {
            flag = 1;
            break;
        }
    }
    if(flag) return 1;
    return 0;
}

// END ASM
