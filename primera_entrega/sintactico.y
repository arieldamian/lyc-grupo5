%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

#define CARACTER_NOMBRE "_"
#define NO_ENCONTRADO -1
#define SIN_ASIGNAR "SinAsignar"
#define TRUE 1
#define FALSE 0
#define ERROR -1
#define OK 3

  enum valorMaximo{
    ENTERO_MAXIMO = 32768,
    CADENA_MAXIMA = 31,
    TAM = 100
  };

  //Polaca
	typedef struct
	{
		char cadena[CADENA_MAXIMA];
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

  /////////////// VARIABLES //////////////////
  int yystopparser=0;
  FILE  *yyin;
  char *yyltext;
	char *yytext;

  int contadorPolaca=0;
  t_polaca polaca;

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
%token OP_IGUAL
%token OP_ASIG
%token OP_SUMA
%token OP_DISTINTO
%token OP_MENORIGUAL
%token OP_MENOR
%token OP_MAYOR
%token OP_DIV
%token OP_MULT
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
  ID {printf("ID es Factor \n");}
  | CTE_ENTERA {printf("CTE real es Factor\n");}
  | CTE_REAL {printf("CTE real es Factor\n");}
  | func_contar {printf("CTE real es Factor\n");}
  ;

func_contar:
  CONTAR PAR_ABRE termino SIMB_PUNTO_COMA lista PAR_CIERRA {printf("CONTAR (termino ; lista) es una FUNC_CONTAR \n");}
  ;

lista:
  lista SIMB_COMA termino {printf("LISTA, TERMINO es una LISTA \n");}
  | COR_ABRE lista COR_CIERRA {printf("[lista] es una LISTA \n");}
  | termino {printf("TERMINO es una LISTA \n");}
  ;

termino: 
 factor {printf("Factor es Termino\n");}
 | termino OP_MULT factor {printf("Termino*Factor es Termino\n");}
 | termino OP_DIV factor {printf("Termino/Factor es Termino\n");}
 | PAR_ABRE termino OP_MULT factor PAR_CIERRA {printf("(Termino*Factor) es Termino\n");}
 | PAR_ABRE termino OP_DIV factor PAR_CIERRA {printf("(Termino/Factor) es Termino\n");}
 ;

declaracion: 
  DIM OP_MENOR variable OP_MAYOR AS OP_MENOR tipo OP_MAYOR {printf("DIM <VARIABLE> AS <TIPO> es una DECLARACION\n");}
  ;

asignacion:
  CONST ID {
    ponerEnPolaca(&polaca, yylval.str_val);
  } 
  OP_IGUAL {
    // insertar en una pila op_igual
    ponerEnPolaca(&polaca, yylval.str_val);
  }
  CTE_ENTERA {
    ponerEnPolaca(&polaca, yylval.int_val);
  } SIMB_PUNTO_COMA {
    // Desapilar el tope de pila e insertar en polaca
    printf("CONST ID = CTE_ENTERA; es ASIGNACION\n");
  }
  | ID OP_ASIG CTE_ENTERA SIMB_PUNTO_COMA {printf("ID: CTE_ENTERA; es ASIGNACION\n");}
  | ID OP_ASIG termino OP_SUMA termino SIMB_PUNTO_COMA  {printf("ID: termino + termino; es ASIGNACION\n");}
  ;

expresion:
  ID OP_MENORIGUAL factor {printf("ID <= factor es EXPRESION \n");}
  | ID OP_MAYOR factor {printf("ID > factor es EXPRESION \n");}
  | ID OP_MENOR factor {printf("ID < factor es EXPRESION \n");}
  | ID OP_DISTINTO factor {printf("ID <> factor es EXPRESION \n");}
  ;

opcondicion:
  AND {printf("AND es op-condicion\n");}
  | OP_OR {printf("OP_OR es op-condicion\n");}
  ;

condicion:
  expresion {printf("expresion es CONDICION\n");}
  | OP_NOT expresion {printf("OP_NOT expresion es CONDICION\n");}
  | condicion opcondicion expresion {printf("condicion OPCONDICION expresion es CONDICION\n");}
  | OP_NOT PAR_ABRE condicion opcondicion expresion PAR_CIERRA {printf("OP_NOT PAR_ABRE condicion opcondicion expresion PAR_CIERRA es CONDICION\n");}
  ;

else:
  ELSE LLAVE_ABRE sentencias LLAVE_CIERRA {printf("else {SENTENCIAS} es ELSE\n");}
  ;

condicional:
  WHILE PAR_ABRE condicion PAR_CIERRA LLAVE_ABRE sentencias LLAVE_CIERRA {printf("WHILE (CONDICION) {SENTENCIAS} es CONDICIONAL\n");}
  | IF PAR_ABRE condicion PAR_CIERRA LLAVE_ABRE sentencia LLAVE_CIERRA else  {printf("IF (CONDICION) {SENTENCIAS} ELSE es CONDICIONAL\n");}
  | IF PAR_ABRE condicion PAR_CIERRA sentencia {printf("IF (CONDICION) SENTENCIAS es CONDICIONAL\n");}
  ;

escritura:
  PUT CADENA_CARACTERES SIMB_PUNTO_COMA {printf("PUT STRING; es ESCRITURA\n");}
  | PUT ID SIMB_PUNTO_COMA {printf("PUT ID; es ESCRITURA\n");}
  ;

lectura:
  GET ID SIMB_PUNTO_COMA {printf("GET ID; es LECTURA\n");}
  ;

%%

int main(int argc, char *argv[]) {
  crearPolaca(&polaca);

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
	void crearPolaca(t_polaca* pp) {
	    *pp=NULL;
	}

	char * sacarDePolaca(t_polaca * pp) {
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

	int ponerEnPolaca(t_polaca* pp, char *cadena) {
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

	int ponerEnPolacaNro(t_polaca* pp,int pos, char *cadena) {
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
		while(*pp)
	    {
	        pn=*pp;
	        fprintf(pt, "%s\n",pn->info.cadena);
	        *pp=(*pp)->psig;
	        //TODO: Revisar si este free afecta al funcionamiento del compilador en W7
	        free(pn);
	    }
		fclose(pt);
	}
