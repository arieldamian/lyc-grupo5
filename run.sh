flex lexico.l
#bison -dyv Sintactico_ClasePractica.y
gcc lex.yy.c -o compilador
./compilador prueba.txt
rm lex.yy.c
rm compilador