#include "structs.h"

node criarNo(char* string) {
    node no = (node)malloc(sizeof(tree_node));
    no->tag = (char*)malloc((strlen(string) + 1) * sizeof(char));
    strcpy(no->tag, string);
    no->filho = NULL;
    no->irmao = NULL;
    return no;
}

node criarNoVazio() {
    node no = (node)malloc(sizeof(tree_node));
    no->tag = NULL;
    no->filho = NULL;
    no->irmao = NULL;
    return no;
}

node criarNoTerminal(char* string, char* valor) {
    node no = (node)malloc(sizeof(tree_node));
    if (valor != NULL) {
        no->tag = (char*)malloc((strlen(string) + strlen(valor) + 3) * sizeof(char));
	sprintf(no->tag, "%s%c%s%c", string, '(', valor, ')');
    } else {
	no->tag = (char*)malloc((strlen(string) + 3) * sizeof(char));
	sprintf(no->tag, "%s%c%c", string, '(', ')');
    }
    no->filho = NULL;
    no->irmao = NULL;
    return no;
}

void criarFilho(node pai, node filho) {
    if(pai == NULL)
        return;
    pai->filho = filho;
}

void criarIrmao(node a, node b) {
    if(a == NULL || b == NULL) {
        return;
    }
    while(a->irmao != NULL) {
        a = a->irmao;
    }
    a->irmao = b;
}

void typeIrmaos(node pai, node type) {
    if(pai == NULL) {
        return;
    }
    node aux_sib = criarNoVazio();
    aux_sib->tag = (char*)malloc((strlen(pai->filho->tag) + 1) * sizeof(char)); 
    strcpy(aux_sib->tag, pai->filho->tag);
    pai->filho->irmao = aux_sib; /*mover filho para irmao*/

    pai->filho->tag = (char*)malloc((strlen(type->tag) + 1) * sizeof(char));
    strcpy(pai->filho->tag, type->tag);
    typeIrmaos(pai->irmao, type);
}

void printTree(node raiz, int profundidade) {
    int aux;
    while (raiz != NULL && strcmp(raiz->tag, "Erro") == 0){
	raiz = raiz->irmao;
    }
    if(raiz == NULL) {
        return;
    } else if (strcmp(raiz->tag, "Erro") != 0) {
	for(aux = 0; aux < profundidade; aux++) {
            printf("..");
        }
        printf("%s\n", raiz->tag);
    } 
    printTree(raiz->filho, profundidade + 1);
    printTree(raiz->irmao, profundidade);

    free(raiz->tag);
    free(raiz->filho);
    free(raiz->irmao);
    if(profundidade == 0) {
        free(raiz);
    }
}

void freeTree(node raiz) {
    if(raiz == NULL) {
        return;
    }
    freeTree(raiz->filho);
    freeTree(raiz->irmao);
    
    free(raiz->tag);
    free(raiz->filho);
    free(raiz->irmao);
}

node verificaErro(node no) {
    if(no == NULL) {
        return criarNo("Erro");
    }
    else {
        return no;
    }
}

