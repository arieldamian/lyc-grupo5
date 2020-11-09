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

typedef char* t_dato;

typedef struct s_nodo {
    t_dato dato;
    struct s_nodo * psig;
}t_nodo;

typedef t_nodo* t_pila;


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
void crear_pila(t_pila * pp);
int poner_en_pila(t_pila * pp, const t_dato * pd);
int sacar_de_pila(t_pila * pp,t_dato * pd);
void vaciar_pila(t_pila * pp);
int ver_tope_pila(const t_pila * pp,t_dato * pd );
int pila_vacia(const t_pila *pp);


#endif //NEWPILA_PILA_H