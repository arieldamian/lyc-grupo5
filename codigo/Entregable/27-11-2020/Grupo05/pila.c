#include "pila.h"
#include <stdlib.h>
#include <string.h>

void crearPila(t_pila* pp)
{
		*pp=NULL;
}

int ponerEnPila(t_pila* pp,t_info* info)
{
		t_nodoPila* pn=(t_nodoPila*)malloc(sizeof(t_nodoPila));
		if(!pn)
				return 0;
		pn->info=*info;
		pn->psig=*pp;
		*pp=pn;
		return 1;
}

t_info * sacarDePila(t_pila* pp)
{
	t_info* info = (t_info *) malloc(sizeof(t_info));
		if(!*pp){
			return NULL;
		}
		*info=(*pp)->info;
		*pp=(*pp)->psig;
		return info;

}

void vaciarPila(t_pila* pp)
{
		t_nodoPila* pn;
		while(*pp)
		{
				pn=*pp;
				*pp=(*pp)->psig;
				free(pn);
		}
}

t_info* topeDePila(t_pila* pila){
	return &((*pila)->info);
}

int pilaVacia(t_pila* pp) {
	return *pp == NULL;	
}
