flex Lexico.l
bison -dyv Sintactico.y
gcc pila.c lex.yy.c y.tab.c -o compilador
./compilador prueba.txt
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compilador