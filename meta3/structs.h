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
void insertGTable(gTable root, char* tagValue, char* typeValue, table param, char isVar);
int searchFuncDec(gTable symTab, char* tagValue, node root);
table searchFuncDef(table root, char* tagValue);
table startAuxTable(node tree, table root, char* tagValue, char* tagType);
void insertInTable(table root, table node);
table getParamList(node root);
int checkFuncDec(node root, gTable symTab, table auxSymTab);
void analiseFuncDec(node root, gTable symTab, table auxSymTab);
table createFuncTable(node root, table auxSymTab);
void analiseDec(node root, gTable symTab);
void analiseDecF(node root, table symTab);
void analiseFuncBody(node root, gTable symTab, table auxSymTab);
int checkDecAtribution(node root, gTable symTab, table auxSymTab);
void printGTable(gTable root);
void printParams(table param);
void printTable(table root);
char* lowerCase(char* string);
int checkDeclaration(gTable symTab, char* dec, node root);
int searchVarDec(table symTab, char* dec);
char* removeId(char* id);
int checkIfVoid(node root);
int checkIfParamVoid(node root);
void checkIfRepeatedParams(node root);
table removeRepeatedParams(table root);
char* getFunctionType(char* type, table symTab);
void annoteFuncBody(node root, gTable symTab, table auxSymTab);
void checkSemantics(node root, gTable symTab, table auxSymTab);
gTable createSymbolGTable(char* tagValue, char* typeValue, table fParams, char isVar);
table createSymbolTable(char* tagValue, char* typeValue);



//annotedTree.c functions
char* checkVarType(char* string);
void checkOperationType(node root, gTable symTab, table auxSymTable);
void annoteTree(node root, gTable symTab, table auxSymTab);
char* annoteFuncParams(gTable symTab);
void analiseStore(node root);
void analiseFuncCall(node root, char* id, gTable symTab);
int analiseFuncId(node root, char* id, gTable symTab);
void analiseVarId(node root, gTable symTab, table auxSymTab);
int checkIfOperation(char* string);
int checkIfLogicalOperation(char* string);
int checkIfSpecialLogicalOperation(char* string);
int checkIfId(char* string);
void annotedDecOp(node root, gTable symTab, table auxSymTab);
void printAnnotedTree(node root, int level);
int getFunctionNrParams(gTable symTab, char* funcName);
char* getOperator(char* operatorTag);
int validateConversion(node root);
int checkIfFunction(char* type);
void checkReturn(node root, char* got, table symTab);

//erros.c funtions
void errorLocation(int line, int col);
void conflictingTypes(int line, int col, char* got, char* expected);
void invalidVoid(int line, int col);
void lValue(int line, int col);
void operatorApplication(int line, int col, char* token, char* type);
void operatorsApplication(int line, int col, char* token, char* type1, char* type2);
void symbolAlreadyDefined(int line, int col, char* token);
void symbolNotFunction(int line, int col, char* token);
void unknownSymbol(int line, int col, char* token);
void wrongArguments(int line, int col, char* token, int got, int expected);

//extern declarations
extern char flag;
extern node root;
extern char printAST;
extern char flagPrintTable;












