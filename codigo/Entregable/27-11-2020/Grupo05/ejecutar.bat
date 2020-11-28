cls
flex .\lexico.l
bison -dyv .\sintactico.y
gcc pila.c funciones.c lex.yy.c y.tab.c -o compilador.exe
compilador.exe prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del compilador.exe