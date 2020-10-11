%{
#include <stdio.h>
#include <stdlib.h>
FILE *yyin;
int yylval;
char *yyltext;
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

{PALABRA_RESERVADA}     printf("\nPALABRA_RESERVADA: %s\n", yytext);
{DIGITO}       			printf("\nDIGITO: %s\n", yytext);
{LETRA}       			printf("\nLETRA: %s\n", yytext);
{CTE_ENTERA}       		printf("\nCTE_ENTERA: %s\n", yytext);
{CTE_REAL}         		printf("\nCTE_REAL: %s\n", yytext);
{CADENA_CARACTERES}     printf("\nCADENA_CARACTERES: %s\n", yytext);
{ID}       				printf("\nID: %s\n", yytext);
{OP_DEC}       			printf("\nOP_DEC: %s\n", yytext);
{OP_ASIG}       		printf("\nOP_ASIG: %s\n", yytext);
{OP_SUMA}       		printf("\nOP_SUMA: %s\n", yytext);
{OP_DISTINTO}       	printf("\nOP_DISTINTO: %s\n", yytext);
{OP_MENORIGUAL}       	printf("\nOP_MENORIGUAL: %s\n", yytext);
{OP_MENOR}       		printf("\nOP_MENOR: %s\n", yytext);
{OP_MAYOR}       		printf("\nOP_MAYOR: %s\n", yytext);
{OP_DIV}       			printf("\nOP_DIV: %s\n", yytext);
{OP_MULT}       		printf("\nOP_MULT: %s\n", yytext);
{PAR_ABRE}       		printf("\nPAR_ABRE: %s\n", yytext);
{PAR_CIERRA}       		printf("\nPAR_CIERRA: %s\n", yytext);
{COR_ABRE}       		printf("\nCOR_ABRE: %s\n", yytext);
{COR_CIERRA}       		printf("\nCOR_CIERRA: %s\n", yytext);
{LLAVE_ABRE}       		printf("\nLLAVE_ABRE: %s\n", yytext);
{LLAVE_CIERRA}       	printf("\nLLAVE_CIERRA: %s\n", yytext);
{SIMB_COMA}       		printf("\nSIMB_COMA: %s\n", yytext);
{SIMB_PUNTO_COMA}       printf("\nSIMB_PUNTO_COMA: %s\n", yytext);
"\n"
"\t"


%%

int main(int argc, char * argv[]) {
	if ((yyin = fopen(argv[1], "rt")) == NULL) {
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	} else {
		yylex();
	}

	fclose(yyin);
	return 0;
}
