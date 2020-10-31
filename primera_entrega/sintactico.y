%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();

%}

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
%token CTE_ENTERA
%token CTE_REAL
%token CADENA_CARACTERES
%token ID
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
  CONST ID OP_IGUAL CTE_ENTERA SIMB_PUNTO_COMA {printf("CONST ID = CTE_ENTERA; es ASIGNACION\n");}
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

int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
       
    }
    else
    { 
        
        yyparse();
        
    }
	fclose(yyin);
        return 0;
}
int yyerror(void)
     {
       printf("Error Sintactico\n");
	     exit (1);
     }
