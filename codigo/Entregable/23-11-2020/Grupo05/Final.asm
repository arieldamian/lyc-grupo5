INCLUDE macros2.asm
INCLUDE number.asm
.MODEL LARGE
.386
.STACK 200h
	.DATA
	TRUE equ 1
	FALSE equ 0
	MAXTEXTSIZE equ 200
contador                        	dd	?
promedio                        	dd	?
actual                          	dd	?
suma                            	dd	?
nombre                          	dd	?
_80                             	dd	80
_"Prueba.txt LyC Tema 4!"       	db	"Prueba.txt LyC Tema 4!",'$', 24 dup (?)
_"Ingrese un valor entero para a"	db	"Ingrese un valor entero para a",'$', 32 dup (?)
_0                              	dd	0
_02.5                           	dd	02.5
_92                             	dd	92
_1                              	dd	1
_"La suma es: "                 	db	"La suma es: ",'$', 14 dup (?)
@aux0                           	dd	?
@aux1                           	dd	?
@aux2                           	dd	?

.CODE
START:
MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

fild nombre
fistp 80
DisplayString "Prueba.txt LyC Tema 4!"
newLine 1
DisplayString "Ingrese un valor entero para actual: "
newLine 1
GetInteger actual
fild contador
fistp 0
fild 02.5
fild nombre
fadd
fistp @aux0
fild @aux0
fistp suma
etiqueta1:
fild 92
fild contador
fcom
fstsw ax
sahf
BGT etiqueta2
fild contador
fild 1
fadd
fistp @aux1
fild @aux1
fistp contador
fild suma
fild actual
fadd
fistp @aux2
fild @aux2
fistp suma
BI etiqueta1
etiqueta2:
DisplayString "La suma es: "
newLine 1
DisplayInteger suma
newLine 1
	ffree
	mov ax, 4c00h
	int 21h
	End START
