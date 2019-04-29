#include "structs.h"

void erroAlreadyDefined(node raiz){ //passesTest
    printf("Line %d, column %d: Symbol %s already defined\n", raiz->line, raiz->column, removeId(raiz->tag));
}

void erroCannotFindSymbolCall(node raiz){
    printf("Line %d, column %d: Cannot find symbol %s(", raiz->line, raiz->column, removeId(raiz->tag));
    while(raiz->irmao != NULL){
	raiz = raiz->irmao;
	printf("%s", raiz->type);
    }
    printf(")\n");
}

void erroWrongType(node raiz, char *type){
	printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", raiz->line, raiz->column, raiz->tag, type);
}
