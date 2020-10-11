%{
#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

%option noyywrap  
%option yylineno 

PALABRA_RESERVADA	DIM|Float|Integer|PUT|GET|CONST|while|if|Else|"AS"|"and"
DIGITO 				[0-9]
LETRA  				[a-zA-Z]
CTE_ENTERA  		{DIGITO}+
CTE_REAL			{DIGITO}+"."{DIGITO}+
CADENA_CARACTERES   \".*\"
ID          		{LETRA}({LETRA}|{DIGITO})*
OP_DEC				"="
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

{PALABRA_RESERVADA}     {printf("\nPALABRA_RESERVADA: %s\n", yytext); return PALABRA_RESERVADA;}
{DIGITO}       			{printf("\nDIGITO: %s\n", yytext); return DIGITO;}
{LETRA}       			{printf("\nLETRA: %s\n", yytext); return LETRA;}
{CTE_ENTERA}       		{printf("\nCTE_ENTERA: %s\n", yytext); return CTE_ENTERA;}
{CTE_REAL}         		{printf("\nCTE_REAL: %s\n", yytext); return CTE_REAL;}
{CADENA_CARACTERES}     {printf("\nCADENA_CARACTERES: %s\n", yytext); return CADENA_CARACTERES;}
{ID}       				{printf("\nID: %s\n", yytext); return ID;}
{OP_DEC}       			{printf("\nOP_DEC: %s\n", yytext); return OP_DEC;}
{OP_ASIG}       		{printf("\nOP_ASIG: %s\n", yytext); return OP_ASIG;}
{OP_SUMA}       		{printf("\nOP_SUMA: %s\n", yytext); return OP_SUMA;}
{OP_DISTINTO}       	{printf("\nOP_DISTINTO: %s\n", yytext); return OP_DISTINTO;}
{OP_MENORIGUAL}       	{printf("\nOP_MENORIGUAL: %s\n", yytext); return OP_MENORIGUAL;}
{OP_MENOR}       		{printf("\nOP_MENOR: %s\n", yytext); return OP_MENOR;}
{OP_MAYOR}       		{printf("\nOP_MAYOR: %s\n", yytext); return OP_MAYOR;}
{OP_DIV}       			{printf("\nOP_DIV: %s\n", yytext); return OP_DIV;}
{OP_MULT}       		{printf("\nOP_MULT: %s\n", yytext); return OP_MULT;}
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
.			printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext );
