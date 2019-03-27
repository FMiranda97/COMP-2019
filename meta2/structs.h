#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct _tree_node* node;
typedef struct _tree_node{
    char* tag;
    node filho;
    node irmao;
}tree_node;

int yylex(void);
void yyerror (char*);
node criarNo(char* );
node criarNoEmpty();
node criarNoTerminal(char* , char* );
void criarFilho(node , node );
void criarIrmao(node , node );
void typeIrmaos(node , node );
void printTree(node , int );
void freeTree(node );

extern char flag;
