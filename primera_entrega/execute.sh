flex lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c -o compilador
./compilador prueba.txt
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compilador