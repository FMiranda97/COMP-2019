#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct _info_node* tokenInfo;
typedef struct _info_node{
    char *nome;
    int line;
    int column;
}info_node;


typedef struct _tree_node* node;
typedef struct _tree_node{
    char* type;
    int line;
    int column;
    char* tag;
    node filho;
    node irmao;
}tree_node;

typedef struct _sym_table* table;
typedef struct _sym_table{
    char* tag;
    char* type;
    char* param;
    table next;
}sym_table;

typedef struct _g_sym_table* gTable;
typedef struct _g_sym_table{
    char* tag;
    char* type;
    char isVar;
    table params;
    gTable next;
}g_sym_table;

//ast.c functions
int yylex(void);
void yyerror (char*);
node criarNo(char*, tokenInfo);
node criarNoEmpty();
node criarNoTerminal(char* , tokenInfo );
void criarFilho(node , node );
void criarIrmao(node , node );
void typeIrmaos(node , node );
void printTree(node , int );
void freeTree(node );
tokenInfo sendInfo(char *text);

//table.c functions
gTable startTable();
gTable createSymbolGTable(char* tagValue, char* typeValue, table fParams, char isVar);
table createSymbolTable(char* tagValue, char* typeValue);
void insertGTable(gTable raiz, char* tagValue, char* typeValue, table param, char isVar);
void insertInTable(table raiz, table node);
void checkSemantics(node raiz, gTable symTab, table auxSymtab);
int checkFuncDec(node raiz, gTable symTab, table auxSymTab);
void analiseDec(node raiz, gTable symTab);
int checkDeclaration(gTable symTab, char* dec, node raiz);
table createFuncTable(node raiz, table auxSymTab);
table startAuxTable(node tree, table raiz, char* tagValue, char* tagType);
void analiseFuncBody(node raiz, gTable symTab, table auxSymTab);
int searchVarDec(table symTab, char* dec);
int searchFuncDec(gTable symTab, char* tagValue, node raiz);
void analiseFuncDec(node raiz, gTable symTab, table auxSymTab);
table getParamList(node raiz);
char* removeId(char* id);
void printGTable(gTable raiz);
void printParams(table param);
void printTable(table raiz);
char* lowerCase(char* string);




//annotedTree.c functions
void annoteTree(node raiz, gTable symTab, table funcTable);
void annoteAssign(node raiz, gTable symTab, table funcTable);
void annoteOperator(node raiz, gTable symTab, table funcTable);
char isOperator(char* string);
char isLogical(char* string);
char* findFuncType(char* funcId, gTable symTab);
int analiseFuncId(node raiz, gTable symTab);
void analiseVarId(node raiz, gTable symTab, table funcTable);
char* annoteFuncParams(gTable symTab);
void printAnnotedTree(node raiz, int level);




//erros.c funtions
void erroAlreadyDefined(node raiz);
void erroWrongType(node raiz, char *type);
void erroCannotFindSymbolCall(node raiz);


//extern declarations
extern char flag;
extern node root;
extern char printAST;
extern char flagPrintTable;












