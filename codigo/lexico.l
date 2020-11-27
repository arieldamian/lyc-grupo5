%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "funciones.h"

#define COTA_INT 2147483647
#define COTA_FLOAT	3.402823E+38
#define TODO_OK 1
#define ERROR 0

FILE  *yyin;
char *yyltext;
%}

%option yylineno 

DIGITO 				[0-9]
LETRA  				[a-zA-Z]
CTE_ENTERA  		{DIGITO}+
CTE_REAL			{DIGITO}+"."{DIGITO}+
CADENA_CARACTERES   \".*\"
COMENTARIO_SIMPLE		"-/"([^-/]|\n)*?"/-"
COMENTARIO_DOBLE		"-/"([^-/]|\n|{COMENTARIO_SIMPLE})*?"/-"
ID          		{LETRA}({LETRA}|{DIGITO})*
OP_IGUAL			"="
OP_ASIG				":"
OP_SUMA				"+"
OP_DISTINTO			"<>"
OP_MENOR			"<"
OP_MAYOR			">"
OP_DIV				"/"
OP_MULT				"*"
OP_MENORIGUAL		"<="
PAR_ABRE			"("
PAR_CIERRA			")"
COR_ABRE			"["
COR_CIERRA			"]"
LLAVE_ABRE			"{"
LLAVE_CIERRA		"}"
SIMB_COMA			","
SIMB_PUNTO_COMA		";"

%%

"DIM"					{printf("\nPALABRA RESERVADA: %s\n", yytext); return DIM;}	
"Float"				{printf("\nPALABRA RESERVADA: %s\n", yytext); return FLOAT;}	
"Integer"			{printf("\nPALABRA RESERVADA: %s\n", yytext); return INTEGER;}	
"PUT"					{printf("\nPALABRA RESERVADA: %s\n", yytext); return PUT;}	
"GET"					{printf("\nPALABRA RESERVADA: %s\n", yytext); return GET;}	
"CONST"				{printf("\nPALABRA RESERVADA: %s\n", yytext); return CONST;}	
"while"				{printf("\nPALABRA RESERVADA: %s\n", yytext); return WHILE;}	
"if"					{printf("\nPALABRA RESERVADA: %s\n", yytext); return IF;}	
"Else"				{printf("\nPALABRA RESERVADA: %s\n", yytext); return ELSE;}	
"AS"					{printf("\nPALABRA RESERVADA: %s\n", yytext); return AS;}	
"and"					{printf("\nPALABRA RESERVADA: %s\n", yytext); return AND;}
"AND"					{printf("\nPALABRA RESERVADA: %s\n", yytext); return AND;}
"contar"			{printf("\nPALABRA RESERVADA: %s\n", yytext); return CONTAR;}
"OR"          {printf("\nPALABRA RESERVADA: %s\n", yytext); return OP_OR;}
"or"          {printf("\nPALABRA RESERVADA: %s\n", yytext); return OP_OR;}
"NOT"         {printf("\nPALABRA RESERVADA: %s\n", yytext); return OP_NOT;}
"not"         {printf("\nPALABRA RESERVADA: %s\n", yytext); return OP_NOT;}
{COMENTARIO_SIMPLE}	{  }
{COMENTARIO_DOBLE}	{  }	
{CTE_ENTERA}       		{
												printf("\nCTE_ENTERA: %s\n", yytext);
												yylval.int_val = strdup(yytext);

												int num = atoi(yytext); 
												if(num >= COTA_INT*(-1) && num <= COTA_INT){
													insertarTablaSimbolos(indicarNombreConstante(strdup(yytext)), T_CTE_INTEGER, strdup(yytext), 0);
													return CTE_ENTERA; 
												}else{
													printf("ERROR - Int fuera de rango.\n");
													exit(1);
												}
											}
{CTE_REAL}         		{
												printf("\nCTE_REAL: %s\n", yytext);
												yylval.real_val = strdup(yytext);

												double n;
												n = atof(yytext);
												
												if(n >= COTA_FLOAT*(-1) && n <= COTA_FLOAT){
													insertarTablaSimbolos(indicarNombreConstante(strdup(yytext)), T_FLOAT, strdup(yytext), 0);
													return CTE_REAL; 
												}else{
													printf("ERROR - Real fuera de rango.\n");
													exit(2);
												}
											}
{CADENA_CARACTERES}		{
							yylval.str_val = strdup(yytext);
							
							int cantCaracteres = strlen(yytext);
							if(cantCaracteres <= 32) { //Cuenta las commillas tambien
								printf("\nCADENA CARATERES: %s\n", yytext);
								
								char * aux = indicarNombreConstanteString(yylval.str_val);
								insertarTablaSimbolos(aux, T_CTE_STRING, strdup(yytext), strlen(yylval.str_val));
								yylval.str_val = aux;

								return CADENA_CARACTERES;
							} else {
								printf("\nCADENA CARATERES: %s\n", yytext);
								char otherString[33];
								strncpy(otherString, yytext, 31);
								otherString[31] = '\"';
								otherString[32] = '\0';

								char * aux = indicarNombreConstanteString(otherString);
								yylval.str_val = aux;
								insertarTablaSimbolos(aux, T_CTE_STRING, otherString, strlen(otherString));
								return CADENA_CARACTERES;
							}
						}
{ID}      			 	{
							printf("\nID: %s\n", yytext);
							yylval.str_val = strdup(yytext);
							insertarTablaSimbolos(yylval.str_val, T_ID, "?", 0);
							
							return ID;
						}
{OP_IGUAL}       		{printf("\nOP_DEC: %s\n", yytext); yylval.cmp_val = strdup(yytext); return OP_IGUAL;}
{OP_ASIG}       		{printf("\nOP_ASIG: %s\n", yytext); yylval.cmp_val = strdup(yytext); return OP_ASIG;}
{OP_SUMA}       		{printf("\nOP_SUMA: %s\n", yytext); yylval.cmp_val = strdup(yytext); return OP_SUMA;}
{OP_DISTINTO}       	{printf("\nOP_DISTINTO: %s\n", yytext); return OP_DISTINTO;}
{OP_MENORIGUAL}       	{printf("\nOP_MENORIGUAL: %s\n", yytext); return OP_MENORIGUAL;}
{OP_MENOR}       		{printf("\nOP_MENOR: %s\n", yytext); return OP_MENOR;}
{OP_MAYOR}       		{printf("\nOP_MAYOR: %s\n", yytext); return OP_MAYOR;}
{OP_DIV}       			{printf("\nOP_DIV: %s\n", yytext); yylval.cmp_val = strdup(yytext); return OP_DIV;}
{OP_MULT}       		{printf("\nOP_MULT: %s\n", yytext); yylval.cmp_val = strdup(yytext); return OP_MULT;}
{PAR_ABRE}       		{printf("\nPAR_ABRE: %s\n", yytext); return PAR_ABRE;}
{PAR_CIERRA}       		{printf("\nPAR_CIERRA: %s\n", yytext); return PAR_CIERRA;}
{COR_ABRE}       		{printf("\nCOR_ABRE: %s\n", yytext); return COR_ABRE;}
{COR_CIERRA}       		{printf("\nCOR_CIERRA: %s\n", yytext); return COR_CIERRA;}
{LLAVE_ABRE}       		{printf("\nLLAVE_ABRE: %s\n", yytext); return LLAVE_ABRE;}
{LLAVE_CIERRA}       	{printf("\nLLAVE_CIERRA: %s\n", yytext); return LLAVE_CIERRA;}
{SIMB_COMA}       		{printf("\nSIMB_COMA: %s\n", yytext); return SIMB_COMA;}
{SIMB_PUNTO_COMA}       {printf("\nSIMB_PUNTO_COMA: %s\n", yytext); return SIMB_PUNTO_COMA;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.						{printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit(18);}


%%
int yywrap() {
	return 1;
}
