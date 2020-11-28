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
_80                             	dd	80.0
_cteString0                     	db	"Prueba.txt LyC Tema 4!",'$', 24 dup (?)
_cteString1                     	db	"Ingrese un valor entero para a",'$', 32 dup (?)
_0                              	dd	0.0
_025                            	dd	02.5
_92                             	dd	92.0
_1                              	dd	1.0
_0342                           	dd	0.342
_256                            	dd	256.0
_52                             	dd	52.0
_4                              	dd	4.0
_cteString2                     	db	"La suma es: ",'$', 14 dup (?)
_2                              	dd	2.0
_cteString3                     	db	"actual es mayor que 2 y distin",'$', 32 dup (?)
_cteString4                     	db	"no es mayor que 2",'$', 19 dup (?)
@aux0                           	dd	?
@aux1                           	dd	?
@aux2                           	dd	?
@aux3                           	dd	?
@aux4                           	dd	?
@aux5                           	dd	?
@aux6                           	dd	?
@aux7                           	dd	?
@aux8                           	dd	?
@aux9                           	dd	?
@aux10                          	dd	?
@aux11                          	dd	?
@aux12                          	dd	?
@aux13                          	dd	?
@aux14                          	dd	?
@aux15                          	dd	?
@aux16                          	dd	?

.CODE
START:
MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

fld _80
fstp nombre
DisplayString _cteString0
newLine 1
DisplayString _cteString1
newLine 1
GetFloat actual
fld _0
fstp contador
fld _025
fld nombre
fadd
fstp @aux0
fld @aux0
fstp suma
etiqueta1:
fld _92
fld contador
fcom
fstsw ax
sahf
JA etiqueta2
fld contador
fld _1
fadd
fstp @aux1
fld @aux1
fstp contador
fld contador
fld _0342
fdiv
fstp @aux2
fld @aux2
fstp @aux3
fld _0
fstp @aux4
fld contador
fld actual
fmul
fstp @aux5
fld @aux5
fstp @aux6
fld _256
fstp @aux7
fld @aux6
fld @aux7
fcom
fstsw ax
sahf
JNE etiqueta3
fld _1
fld @aux4
fadd
fstp @aux8
fld @aux8
fstp @aux4
etiqueta3:
fld suma
fld nombre
fmul
fstp @aux9
fld @aux9
fstp @aux7
fld @aux6
fld @aux7
fcom
fstsw ax
sahf
JNE etiqueta4
fld _1
fld @aux4
fadd
fstp @aux10
fld @aux10
fstp @aux4
etiqueta4:
fld _52
fstp @aux7
fld @aux6
fld @aux7
fcom
fstsw ax
sahf
JNE etiqueta5
fld _1
fld @aux4
fadd
fstp @aux11
fld @aux11
fstp @aux4
etiqueta5:
fld _4
fstp @aux7
fld @aux6
fld @aux7
fcom
fstsw ax
sahf
JNE etiqueta6
fld _1
fld @aux4
fadd
fstp @aux12
fld @aux12
fstp @aux4
etiqueta6:
fld contador
fld @aux4
fmul
fstp @aux13
fld @aux13
fstp @aux14
fld @aux3
fld @aux14
fadd
fstp @aux15
fld @aux15
fstp actual
fld suma
fld actual
fadd
fstp @aux16
fld @aux16
fstp suma
JMP etiqueta1
etiqueta2:
DisplayString _cteString2
newLine 1
DisplayFloat suma, 2
newLine 1
fld _2
fld actual
fcom
fstsw ax
sahf
JNA etiqueta7
fld _0
fld actual
fcom
fstsw ax
sahf
JE etiqueta7
DisplayString _cteString3
newLine 1
JMP etiqueta8
etiqueta7:
fld nombre
fld actual
fcom
fstsw ax
sahf
JAE etiqueta8
DisplayString _cteString4
newLine 1
JMP etiqueta8
etiqueta8:
	ffree
	mov ax, 4c00h
	int 21h
	End START
