%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "pila.h"
#include "funciones.h"

#define CARACTER_NOMBRE "_"
#define NO_ENCONTRADO -1
#define SIN_ASIGNAR "SinAsignar"
#define TRUE 1
#define FALSE 0
#define ERROR -1
#define OK 3

  //Polaca
typedef struct
{
	char cadena[50];
	int nro;
}t_infoPolaca;

typedef struct s_nodoPolaca{
	t_infoPolaca info;
	struct s_nodoPolaca* psig;
}t_nodoPolaca;

typedef t_nodoPolaca *t_polaca;


///////////////////// DECLARACION DE FUNCIONES /////////////////////
int yyerror();
int yylex();

	//Funciones para notacion intermedia
void guardarPolaca(t_polaca*);
int ponerEnPolacaNro(t_polaca*,int, char *);
int ponerEnPolaca(t_polaca*, char *);
void crearPolaca(t_polaca*);
char* obtenerSalto(enum tipoSalto);
char* obtenerSalto2(char*,enum tipoSalto);
char* itoa(int val);
/////////////// VARIABLES //////////////////
int yystopparser=0;
FILE  *yyin;
char *yyltext;
char *yytext;

int contadorPolaca=0;
t_polaca polaca;

t_pila pila;
t_pila pilaAux;
t_pila pilaTerminales;
t_pila pilaCond;
  
int asigSuma = 0;
int isWhile = 0;
int isIf = 0;
int isIfAnidado = 0;
int isContar = 0;
int isContarLista = 0;
int isOperacion = 0;
%}

%union {
	char * int_val;
	char * real_val;
	char * str_val;
	char * cmp_val;
}

%token DIM
%token FLOAT
%token INTEGER
%token PUT
%token GET
%token CONST
%token WHILE
%token IF
%token ELSE
%token AS
%token AND
%token CONTAR
%token <int_val>CTE_ENTERA
%token <real_val>CTE_REAL
%token <str_val>CADENA_CARACTERES
%token <str_val>ID
%token <cmp_val>OP_IGUAL
%token <cmp_val>OP_ASIG
%token <cmp_val>OP_SUMA
%token OP_DISTINTO
%token OP_MENORIGUAL
%token OP_MENOR
%token OP_MAYOR
%token <cmp_val>OP_DIV
%token <cmp_val>OP_MULT
%token OP_OR
%token OP_NOT
%token PAR_ABRE
%token PAR_CIERRA
%token COR_ABRE
%token COR_CIERRA
%token LLAVE_ABRE
%token LLAVE_CIERRA
%token SIMB_COMA
%token SIMB_PUNTO_COMA

%%

program:
	sentencias {
		mostrarTablaSimbolos();
		tsCrearArchivo();
		generarAssembler();
		printf("\n--------------FIN PROGRAMA--------------\n");
	}

sentencias:
  sentencia
  | sentencias sentencia
  ;

sentencia:  	   
  declaracion {printf("--------------FIN DECLARACION--------------\n");}
  | asignacion {printf("--------------FIN ASIGNACION--------------\n");}
  | escritura {printf("--------------FIN ESCRITURA--------------\n");}
  | lectura {printf("--------------FIN LECTURA--------------\n");}
  | condicional {printf("--------------FIN CONDICIONAL--------------\n");}
  ;

variable:
  ID {printf("ID es VARIABLE\n");}
  | variable SIMB_COMA ID {printf("variable,ID es VARIABLE\n");}
  ;

tipo:
  FLOAT {printf("FLOAT es TIPO\n");}
  | INTEGER {printf("INTEGER es TIPO\n");}
  | tipo SIMB_COMA FLOAT {printf("tipo , FLOAT es TIPO\n");}
  | tipo SIMB_COMA INTEGER {printf("tipo , INTEGER es TIPO\n");}
  ;

factor: 
  ID {
	if ((isWhile && !asigSuma) || isIf || isContar || isOperacion) {
		ponerEnPolaca(&polaca, yylval.str_val);
	} else {
		t_info info;
		info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
		strcpy(info.cadena, yylval.str_val);
		ponerEnPila(&pilaTerminales,  &info);
	}

    printf("ID es Factor \n");
  }
  | CTE_ENTERA {
	if (isContarLista) {
		ponerEnPolaca(&polaca, "@aux");
		ponerEnPolaca(&polaca, yylval.int_val);
		ponerEnPolaca(&polaca, "=");
	} else if (isIf || isIfAnidado || isContar || isWhile || isOperacion) {
		ponerEnPolaca(&polaca, yylval.int_val);
		isIf = 0;
		isWhile = 0;
	} else {
		t_info info;
		info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
		strcpy(info.cadena, yylval.int_val);
		ponerEnPila(&pilaTerminales,  &info);
	}

    printf("CTE entera es Factor\n");
  }
  | CTE_REAL {
	if (isOperacion) {
		ponerEnPolaca(&polaca, yylval.real_val);
	} else {
		t_info info;
		info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
		strcpy(info.cadena, yylval.real_val);
		ponerEnPila(&pilaTerminales,  &info);
	}
    printf("CTE real es Factor\n");
  }
  | func_contar {printf("func CONTAR es Factor\n");}
  ;

func_contar:
  CONTAR {
	  isContar = 1;
	  ponerEnPolaca(&polaca, "@cont");
	  ponerEnPolaca(&polaca, "0");
	  ponerEnPolaca(&polaca, "=");
	} PAR_ABRE termino {
	ponerEnPolaca(&polaca,"=");
	ponerEnPolaca(&polaca,"@pivot");
  } SIMB_PUNTO_COMA lista PAR_CIERRA {
	  isContar = 0;
	  ponerEnPolaca(&polaca,"@cont");
	  printf("CONTAR (termino ; lista) es una FUNC_CONTAR \n");
	}
  ;

lista:
  termino {
	  ponerEnPolaca(&polaca, "@aux");
	  ponerEnPolaca(&polaca, "@pivot");
	  ponerEnPolaca(&polaca, "CMP");
	  ponerEnPolaca(&polaca, "BNE");
	  
	  int pos = contadorPolaca;
	  ponerEnPolaca(&polaca, "");
	  
	  ponerEnPolaca(&polaca, "@cont");
	  ponerEnPolaca(&polaca, "1");
	  ponerEnPolaca(&polaca, "=");

	  ponerEnPolacaNro(&polaca, pos, itoa(contadorPolaca));

	  printf("TERMINO es una LISTA \n");
	}
  | lista SIMB_COMA termino {
	  
	  ponerEnPolaca(&polaca, "@aux");
	  ponerEnPolaca(&polaca,"@pivot");
	  ponerEnPolaca(&polaca, "CMP");
	  ponerEnPolaca(&polaca, "BNE");
	  
	  int pos = contadorPolaca;
	  ponerEnPolaca(&polaca, "");
	  
	  ponerEnPolaca(&polaca, "@cont");
	  ponerEnPolaca(&polaca, "1");
	  ponerEnPolaca(&polaca, "+");
	  ponerEnPolaca(&polaca, "=");
	  ponerEnPolaca(&polaca, "@cont");

	  ponerEnPolacaNro(&polaca, pos, itoa(contadorPolaca));

	  printf("LISTA, TERMINO es una LISTA \n");
	}
  | COR_ABRE {isContarLista = 1;} lista COR_CIERRA {
	  isContarLista = 0;
	  printf("[lista] es una LISTA \n");
	}
  ;

term:
  termino OP_MULT {
	t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, yylval.cmp_val);
    ponerEnPila(&pila,  &info);
  } factor {
	t_info* info = sacarDePila(&pila);
	ponerEnPolaca(&polaca,info->cadena);
	printf("Termino*Factor es Termino\n");
	if (isContarLista) {
      ponerEnPolaca(&polaca, "@aux");
	  ponerEnPolaca(&polaca, "=");
	}
  } | termino OP_DIV {
	t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, yylval.cmp_val);
    ponerEnPila(&pila,  &info);
  } factor{
	  t_info* info = sacarDePila(&pila);
	  ponerEnPolaca(&polaca,info->cadena);
	  printf("Termino/Factor es Termino\n");
	}
  ;

termino: 
 factor {printf("Factor es Termino\n");}
 | term
 | PAR_ABRE {isOperacion = 1;} term PAR_CIERRA{
	 isOperacion = 0;
	 printf("(Termino*Factor) es Termino\n");
	}
 ;

declaracion: 
  DIM OP_MENOR variable OP_MAYOR AS OP_MENOR tipo OP_MAYOR {printf("DIM <VARIABLE> AS <TIPO> es una DECLARACION\n");}
  ;

asignacion:
  CONST ID {
    ponerEnPolaca(&polaca, yylval.str_val);
  } 
  OP_IGUAL {
    t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, yylval.cmp_val);
    ponerEnPila(&pila,  &info);
  }
  CTE_ENTERA {
    ponerEnPolaca(&polaca, yylval.int_val);
  }
   SIMB_PUNTO_COMA {
    t_info* info = sacarDePila(&pila);
	ponerEnPolaca(&polaca,info->cadena);
  }
  | ID {
	t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, yylval.str_val);
	ponerEnPila(&pila,  &info);
  }
  OP_ASIG {
	t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, yylval.cmp_val);
	ponerEnPila(&pilaAux,  &info);
  }
  operacion SIMB_PUNTO_COMA {
	if(asigSuma) {
		while(!pilaVacia(&pilaTerminales)){
			t_info* info = sacarDePila(&pilaTerminales);
			ponerEnPolaca(&polaca,info->cadena);
		}

		while(!pilaVacia(&pila)){
			t_info* info = sacarDePila(&pila);
			ponerEnPolaca(&polaca,info->cadena);
		}

		while(!pilaVacia(&pilaAux)){
			t_info* info = sacarDePila(&pilaAux);
			ponerEnPolaca(&polaca,info->cadena);
		}

		asigSuma = 0;
	} else {
		if(!pilaVacia(&pila)){
			t_info* info = sacarDePila(&pila);
			ponerEnPolaca(&polaca,info->cadena);
		}
		if(!pilaVacia(&pilaTerminales)){
			t_info* info = sacarDePila(&pilaTerminales);
			ponerEnPolaca(&polaca,info->cadena);
		}
		if(!pilaVacia(&pilaAux)){
			t_info* info = sacarDePila(&pilaAux);
			ponerEnPolaca(&polaca,info->cadena);
		}
	}
	
	printf("ID : operacion es ASIGNACION \n");
  }
  ;

operacion:
  termino {
	asigSuma = 0;
  }
  | termino OP_SUMA {
	asigSuma = 1;
    t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, yylval.cmp_val);
	ponerEnPila(&pila,  &info);
  } termino
  ;

expresion:
  ID {
	  ponerEnPolaca(&polaca, yylval.str_val);
  } OP_MENORIGUAL {
	  t_info info;
	  info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	  strcpy(info.cadena, "BGT");
	  ponerEnPila(&pilaAux, &info);
	  t_info info2;
	  info2.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	  strcpy(info2.cadena, "CMP");
	  ponerEnPila(&pilaAux, &info2);
  } factor {
	t_info* info = sacarDePila(&pilaAux);
	ponerEnPolaca(&polaca,info->cadena);
	info = sacarDePila(&pilaAux);
	ponerEnPolaca(&polaca,info->cadena);
	printf("ID <= factor es EXPRESION \n");
  }
  | ID {
	ponerEnPolaca(&polaca, yylval.str_val);
  } OP_MAYOR {
	t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, "BLE");
	ponerEnPila(&pilaAux, &info);

	t_info info2;
	info2.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info2.cadena, "CMP");
	ponerEnPila(&pilaAux, &info2);
  } factor {
	t_info* info = sacarDePila(&pilaAux);
	ponerEnPolaca(&polaca,info->cadena);
	info = sacarDePila(&pilaAux);
	ponerEnPolaca(&polaca,info->cadena);
	printf("ID > factor es EXPRESION \n");
  }
  | ID {
	  ponerEnPolaca(&polaca, yylval.str_val);
  } OP_MENOR {
	  t_info info;
	  info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	  strcpy(info.cadena, "BGE");
	  ponerEnPila(&pilaAux, &info);
	  t_info info2;
	  info2.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	  strcpy(info2.cadena, "CMP");
	  ponerEnPila(&pilaAux, &info2);
  } factor {
	  t_info* info = sacarDePila(&pilaAux);
	  ponerEnPolaca(&polaca,info->cadena);
	  info = sacarDePila(&pilaAux);
	  ponerEnPolaca(&polaca,info->cadena);
	  printf("ID < factor es EXPRESION \n");
	}
  | ID {
	  ponerEnPolaca(&polaca, yylval.str_val);
  } OP_DISTINTO {
	  t_info info;
	  info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	  strcpy(info.cadena, "BE");
	  ponerEnPila(&pilaAux, &info);
	  t_info info2;
	  info2.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	  strcpy(info2.cadena, "CMP");
	  ponerEnPila(&pilaAux, &info2);
  } factor {
	t_info* info = sacarDePila(&pilaAux);
	ponerEnPolaca(&polaca,info->cadena);
	info = sacarDePila(&pilaAux);
	ponerEnPolaca(&polaca,info->cadena);
	printf("ID <> factor es EXPRESION \n");
  }
  ;

opcondicion:
  AND {
	isIfAnidado = 1;
	printf("AND es op-condicion\n");
  }
  | OP_OR {
	isIfAnidado = 1;
	printf("OP_OR es op-condicion\n");
  }
  ;

condicion:
  expresion {
	t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, itoa(contadorPolaca));
	ponerEnPolaca(&polaca, "");
	ponerEnPila(&pilaCond,  &info);
    printf("expresion es CONDICION\n");
  }
  | OP_NOT expresion {printf("OP_NOT expresion es CONDICION\n");}
  | condicion opcondicion expresion {
	  t_info info;
	  info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	  strcpy(info.cadena, itoa(contadorPolaca));
      ponerEnPolaca(&polaca, "");
	  ponerEnPila(&pilaCond,  &info);
	  printf("condicion OPCONDICION expresion es CONDICION\n");
	  isIfAnidado = 0;
	}
  | OP_NOT PAR_ABRE condicion opcondicion expresion PAR_CIERRA {printf("OP_NOT PAR_ABRE condicion opcondicion expresion PAR_CIERRA es CONDICION\n");}
  ;

else:
  ELSE LLAVE_ABRE sentencias LLAVE_CIERRA {printf("else {SENTENCIAS} es ELSE\n");}
  ;

ramaif:
	LLAVE_ABRE sentencias LLAVE_CIERRA {
	ponerEnPolaca(&polaca, "BI");
	t_info* info;
	while(!pilaVacia(&pilaCond)) {
		info = sacarDePila(&pilaCond);
		ponerEnPolacaNro(&polaca, atoi(info->cadena), itoa(contadorPolaca+1));
	}
	
	t_info info2;
	info2.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info2.cadena, itoa(contadorPolaca));
	ponerEnPila(&pilaCond,  &info2);
	ponerEnPolaca(&polaca, "");
  } else {
	ponerEnPolaca(&polaca, "BI");
	t_info* info;
	while(!pilaVacia(&pilaCond)) {
		info = sacarDePila(&pilaCond);
		ponerEnPolacaNro(&polaca, atoi(info->cadena), itoa(contadorPolaca));
	}
	
	t_info info2;
	info2.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info2.cadena, itoa(contadorPolaca));
	ponerEnPila(&pilaCond,  &info2);
	ponerEnPolaca(&polaca, "");
  } | sentencia;

condicional:
  WHILE {
	t_info info;
	info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
	strcpy(info.cadena, itoa(contadorPolaca));
	ponerEnPila(&pilaCond, &info);
	ponerEnPolaca(&polaca, "ET");
	isWhile = 1;
  } PAR_ABRE condicion PAR_CIERRA LLAVE_ABRE sentencias LLAVE_CIERRA {
	  ponerEnPolaca(&polaca, "BI");
	  t_info* info = sacarDePila(&pilaCond);
	  ponerEnPolacaNro(&polaca, atoi(info->cadena), itoa(contadorPolaca+1));
	  info = sacarDePila(&pilaCond);
	  ponerEnPolaca(&polaca, info->cadena);
	  isWhile = 0;
	  printf("WHILE (CONDICION) {SENTENCIAS} es CONDICIONAL\n");
	}
  | IF {
	isIf = 1;
  } PAR_ABRE condicion PAR_CIERRA ramaif 
  ;

escritura:
  PUT CADENA_CARACTERES {
		ponerEnPolaca(&polaca, "PUT");
		ponerEnPolaca(&polaca, yylval.str_val);
	} SIMB_PUNTO_COMA {
		printf("PUT STRING; es ESCRITURA\n");
  }
  | PUT ID {
		ponerEnPolaca(&polaca, "PUT");
		ponerEnPolaca(&polaca, yylval.str_val);
	} SIMB_PUNTO_COMA {
		printf("PUT ID; es ESCRITURA\n");
  }
  ;

lectura:
  GET ID {
		ponerEnPolaca(&polaca, "GET");
		ponerEnPolaca(&polaca, yylval.str_val);
	} SIMB_PUNTO_COMA {
  	printf("GET ID; es LECTURA\n");	  
  }
  ;

%%

int main(int argc, char *argv[]) {
  crearPolaca(&polaca);
  crearPila(&pila);
  crearPila(&pilaAux);
  crearPila(&pilaTerminales);
  crearPila(&pilaCond);

  if((yyin = fopen(argv[1], "rt"))==NULL) {
    printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);     
  } else {     
    yyparse();    
  }
  fclose(yyin);

  guardarPolaca(&polaca);
  printf("\n* COMPILACION EXITOSA *\n");
  return 0;
}

int yyerror(void) {
  printf("Error Sintactico\n");
  exit (1);
}

/////////////////POLACA/////////////////////////////////////////////////////
void crearPolaca(t_polaca* pp)
{
	*pp=NULL;
}

char * sacarDePolaca(t_polaca * pp){
	t_nodoPolaca* nodo;
	t_nodoPolaca* anterior;
	char * cadena = (char*)malloc(sizeof(char)*CADENA_MAXIMA);;
	nodo = *pp;

	while(nodo->psig){
		anterior = nodo;
		nodo = nodo->psig;
	}

	anterior->psig=NULL;
	strcpy(cadena, nodo->info.cadena);
	free(nodo);
	return cadena;
}

int ponerEnPolaca(t_polaca* pp, char *cadena)
{
	t_nodoPolaca* pn = (t_nodoPolaca*)malloc(sizeof(t_nodoPolaca));
	if(!pn){
		printf("ponerEnPolaca: Error al solicitar memoria (pn).\n");
		return ERROR;
	}
	t_nodoPolaca* aux;
	strcpy(pn->info.cadena,cadena);
	pn->info.nro=contadorPolaca++;
	pn->psig=NULL;
	if(!*pp){
		*pp=pn;
		return OK;
	}
	else{
		aux=*pp;
		while(aux->psig)
			aux=aux->psig;
		aux->psig=pn;
		return OK;
	}
}

int ponerEnPolacaNro(t_polaca* pp,int pos, char *cadena)
{
	t_nodoPolaca* aux;
	aux=*pp;
	while(aux!=NULL && aux->info.nro<pos){
		aux=aux->psig;
	}
	if(aux->info.nro==pos){
		strcpy(aux->info.cadena,cadena);
		return OK;
	}
	else{
		printf("NO ENCONTRADO\n");
		return ERROR;
	}
	return ERROR;
}

void guardarPolaca(t_polaca *pp) {
	FILE*pt=fopen("intermedia.txt","w+");
	t_nodoPolaca* pn;
	if(!pt){
		printf("Error al crear la tabla de simbolos\n");
		return;
	}
	int i = 0;
	while(*pp)
	{
		pn=*pp;
		fprintf(pt, "%s\n", pn->info.cadena);
		i++;
		*pp=(*pp)->psig;
		//TODO: Revisar si este free afecta al funcionamiento del compilador en W7
		free(pn);
	}
	fclose(pt);
}

char* itoa(int val){
	static char buf[32] = {0};
	int i = 30;
	for(; val && i ; --i, val /= 10)
		buf[i] = "0123456789abcdef"[val % 10];
		
	return &buf[i+1];
}