//
// Created by Matias Dastugue on 9/22/17.
//

#ifndef NEWPILA_PILA_H
#define NEWPILA_PILA_H
#include <stdio.h>
/*
typedef struct{
    void * pilaVec[TAM];
    int tope;
    size_t treg;
}t_pila;
*/

//Utilizando pila con lista enlazada.
//Pila
enum valorMaximo{
		ENTERO_MAXIMO = 32768,
		CADENA_MAXIMA = 31,
		TAM = 100
	};

	enum tipoDato{
		tipoEntero,
		tipoReal,
		tipoCadena,
		tipoArray,
		sinTipo
	};

	enum sectorTabla{
		sectorVariables,
		sectorConstantes
	};

	enum error{
		ErrorIdRepetida,
		ErrorIdNoDeclarado,
		ErrorArraySinTipo,
		ErrorArrayFueraDeRango,
		ErrorLimiteArrayNoPermitido,
		ErrorOperacionNoValida,
		ErrorIdDistintoTipo,
		ErrorConstanteDistintoTipo,
		ErrorArrayAsignacionMultiple,
		ErrorTipoAverage
	};

	enum tipoDeError{
		ErrorSintactico,
		ErrorLexico
	};

	enum tipoCondicion{
		condicionIf,
		condicionRepeat
	};

	enum and_or{
		and,
		or,
		condicionSimple
	};

	enum tipoSalto{
		normal,
		inverso
	};

	typedef struct
	{
		char *cadena;
	}t_info;

	typedef struct s_nodoPila{
    	t_info info;
    	struct s_nodoPila* psig;
	}t_nodoPila;

	typedef t_nodoPila *t_pila;



/*
int poner_en_pila(t_pila * pp, const void * pd);
int sacar_de_pila(t_pila * pp,void * pd);
int ver_tope_pila(const t_pila * pp,void * pd );
void vaciar_pila(t_pila * pp);
int pila_vacia(const t_pila *pp);
int pila_llena(const t_pila *pp);
void crear_pila(t_pila * pp,size_t treg);
*/

//Implementando pila en lista enlazada
//Funciones para manejo de pilas
	void vaciarPila(t_pila*);
	t_info* sacarDePila(t_pila*);
	void crearPila(t_pila*);
	int ponerEnPila(t_pila*,t_info*);
	t_info* topeDePila(t_pila*);
	int pilaVacia(t_pila* pp);


#endif //NEWPILA_PILA_H