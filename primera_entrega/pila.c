//
// Created by Matias Dastugue on 9/22/17.
//
#include "pila.h"
#include <stdlib.h>
#include <string.h>

/*
void crear_pila(t_pila * pp,size_t treg){
    pp->treg = treg;
    pp->tope = -1;
}
int poner_en_pila(t_pila * pp, const void * pd){
    if((pp->tope) < TAM){
        pp->tope+=1;
        pp->pilaVec[pp->tope] = malloc(pp->treg);
        memcpy(pp->pilaVec[pp->tope],pd,pp->treg);
        return 1;
    }else return 0;
}
int sacar_de_pila(t_pila * pp,void * pd){
    if((pp->tope) > -1){
        memcpy(pd,pp->pilaVec[pp->tope],pp->treg);
        free(pp->pilaVec[pp->tope]);
        pp->tope--;
        return 1;
    }else return 0;
}
int ver_tope_pila(const t_pila * pp,void * pd ){
    if(pp->tope > -1){
        memcpy(pd,pp->pilaVec[pp->tope],pp->treg);
        return 1;
    }else return 0;
}
int pila_vacia(const t_pila *pp){
    return pp->tope < 0;
}
int pila_llena(const t_pila *pp){
    return pp->tope == TAM -1;
}
void vaciar_pila(t_pila * pp){
    while(pp->tope >= 0) {
        free(pp->pilaVec[pp->tope]);
        pp->tope--;
    }
    pp->tope = -1;
}
 */

//Implementando una pila en lista enlazada


void crear_pila(t_pila * pp){
    *pp = NULL;
}

int poner_en_pila(t_pila * pp, const t_dato * pd){
    t_nodo *pnue = (t_nodo *) malloc(sizeof(t_nodo));
    if(!pnue) return 0;
    pnue->dato = *pd;
    pnue->psig = *pp;
    *pp = pnue;
    return 1;
}

// int sacar_de_pila(t_pila * pp,t_dato * pd){
//     t_nodo * nodoAux;
//     printf("Sacar de pila 1\n");
//     if(!*pp) return 0;
//     printf("Sacar de pila 2\n");
//     *pd = (*pp)->dato;
//     printf("Sacar de pila 3: %s\n", pd);
//     nodoAux = *pp;
//     printf("Sacar de pila 4\n");
//     *pp = (*pp)->psig;
//     printf("Sacar de pila 5\n");
//     free(nodoAux);
//     return 1;
// }

int sacar_de_pila(t_pila * p, t_dato *d)
{
    t_nodo *elim;

    if(*p == NULL)
        return 0;
    else
    {   
        printf("Sacar de pila 1\n");
        elim = *p;
        printf("Sacar de pila 2\n");
        *p = elim->psig;
        printf("Sacar de pila 3\n");
        *d = elim->dato;
        printf("Sacar de pila 4\n");
        free(elim);
        printf("Sacar de pila 5\n");
        return 1;
    }

}

void vaciar_pila(t_pila * pp){
    t_nodo * nodoAux;
    while(*pp){
        nodoAux = *pp;
        *pp = (*pp)->psig;
        free(nodoAux);
    }
}

int pila_vacia(const t_pila *pp){
    return (*pp == NULL);
}

int pila_llena(const t_pila *pp){
    t_nodo *pnue = (t_nodo *) malloc(sizeof(t_nodo));
    free(pnue);
    return !pnue;
}

int ver_tope_pila(const t_pila * pp,t_dato * pd){
    if(!*pp) return 0;
    *pd = (*pp)->dato;
    return 1;
}