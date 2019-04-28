#include "structs.h"

gTable startTable() {
    gTable symTab;
    symTab = createSymbolGTable("===== Global Symbol Table =====", "", NULL, 'y');
    return symTab;
}

gTable createSymbolGTable(char* tagValue, char* typeValue, table fParams, char isVar) {
    gTable aux = (gTable)malloc(sizeof(g_sym_table));
    aux->tag = (char*)malloc((strlen(tagValue) + 1) * sizeof(char));
    strcpy(aux->tag, tagValue);
    aux->type = (char*)malloc((strlen(typeValue) + 1) * sizeof(char));
    strcpy(aux->type, typeValue);
    aux->params = fParams;
    aux->next = NULL;
    aux->isVar = isVar;
    return aux;
}

table createSymbolTable(char* tagValue, char* typeValue) {
    table aux = (table)malloc(sizeof(sym_table));
    aux->tag = (char*)malloc((strlen(tagValue) + 1) * sizeof(char));
    strcpy(aux->tag, tagValue);
    aux->type = (char*)malloc((strlen(typeValue) + 1) * sizeof(char));
    strcpy(aux->type, typeValue);
    aux->next = NULL;
    aux->param = NULL;
    return aux;
}

void insertGTable(gTable raiz, char* tagValue, char* typeValue, table param, char isVar) {
    while(raiz->next != NULL) {
        raiz = raiz->next;
    }
    raiz->next = createSymbolGTable(tagValue, typeValue, param, isVar);
}

void insertInTable(table raiz, table node) { //insere linha na tabela de uma funcao
    while(strcmp(raiz->next->tag, "") != 0) {
        raiz = raiz->next;
    }
    node->next = raiz->next;
    raiz->next = node;
}

void checkSemantics(node raiz, gTable symTab, table auxSymtab) {
    int aux;
    if (raiz == NULL) return;
    aux = checkFuncDec(raiz, symTab, auxSymtab);
    checkSemantics(raiz->irmao, symTab, auxSymtab);
}

int checkFuncDec(node raiz, gTable symTab, table auxSymTab){//returns 1 if FuncDecl was found
    table func = NULL; 
    if (strcmp(raiz->tag, "FuncDecl") == 0) {
	if(searchFuncDec(symTab, removeId(raiz->filho->filho->tag), raiz) == 0) {
	    analiseFuncDec(raiz, symTab, auxSymTab);
	    func = createFuncTable(raiz, auxSymTab);
	    analiseFuncBody(raiz->filho->irmao->filho, symTab, func); //first element of funcbody
	}
	return 1;
    }else if(strcmp(raiz->tag, "VarDecl") == 0) {
	if(checkDeclaration(symTab, removeId(raiz->filho->irmao->tag), raiz) == 0)
	    analiseDec(raiz, symTab);
    }
    return 0;
}

void analiseDec(node raiz, gTable symTab) { //poe variavel na tabela
    char* aux;

    aux = removeId(raiz->filho->irmao->tag);
    insertGTable(symTab, aux, lowerCase(raiz->filho->tag), NULL, 'y');

    free(aux);
}

int checkDeclaration(gTable symTab, char* dec, node raiz) {
    while(symTab != NULL){
	if(strcmp(dec, symTab->tag) == 0) return 1;
	symTab = symTab->next;
    }
    return 0;
}

table createFuncTable(node raiz, table auxSymTab) {
    table func, params;
    char* aux = removeId(raiz->filho->filho->tag);
    if (raiz->filho->filho->irmao->irmao != NULL)
	params = getParamList(raiz->filho->filho->irmao->irmao);
    else params = getParamList(raiz->filho->filho->irmao);
    //aux = (char*)realloc(aux, strlen(aux) + 17);
    aux = (char*)realloc(aux, 500);
    sprintf(aux, "===== Function %s(", strdup(aux));
    if (params != NULL && strcmp(params->type, "") != 0){
    	while(params != NULL && strcmp(params->type, "") != 0){
	    //aux = (char*)realloc(aux, strlen(aux) + strlen(params->type));
	    sprintf(aux, "%s%s,", strdup(aux), strdup(params->type));
	    params = params->next;
    	}
    	aux[strlen(aux)-1] = '\0'; //delete last comma
    }
    //aux = (char*)realloc(aux, strlen(aux) + 20);
    sprintf(aux, "%s) Symbol Table =====", strdup(aux));
    if(raiz->filho->filho->irmao->irmao != NULL)
	func = startAuxTable(raiz, auxSymTab, aux, raiz->filho->filho->irmao->tag);
    else func = startAuxTable(raiz, auxSymTab, aux, "none");
    return func;
}

table startAuxTable(node tree, table raiz, char* tagValue, char* tagType) {
    char* funcName = removeId(tree->filho->filho->tag);
    table aux = NULL;
    table aux1 = NULL;
    table params;
    if (tree->filho->filho->irmao->irmao != NULL)
	params = getParamList(tree->filho->filho->irmao->irmao);
    else params = getParamList(tree->filho->filho->irmao);

    while(raiz->next != NULL) {
        if(raiz->next->param != NULL && (strcmp(raiz->next->param, funcName) == 0))
            break;
        raiz = raiz->next;
    }
    if(raiz->next != NULL) {
        aux1 = raiz->next->next;
        free(raiz->next->param);
        free(raiz->next->tag);
        free(raiz->next->type);
        free(raiz->next);
    }
    raiz->next = createSymbolTable(tagValue, "");
    raiz->next->next = createSymbolTable("return", lowerCase(tagType));
    if(params != NULL) {
        aux = raiz->next->next;
        while(params != NULL) { //caso tenha parametros poe os na tabela
            if(strcmp(params->tag, "") != 0) {
                aux->next = createSymbolTable(strdup(params->tag), strdup(params->type));
                aux = aux->next;
                aux->param = strdup("param");
            }
            params = params->next;
        }
        aux->next = createSymbolTable("", "");
        if(aux1)
            aux->next->next = aux1;
    }
    else {
        raiz->next->next->next = createSymbolTable("", "");
        if(aux1)
            raiz->next->next->next->next = aux1;
    }
    raiz = raiz->next;
    free(funcName);
    return raiz;
}

void analiseFuncBody(node raiz, gTable symTab, table auxSymTab) { //auxSymTab is table of this function
    if(raiz == NULL) return;
    
    int aux = 1;

    if(strcmp(raiz->tag, "VarDecl") == 0) {
        if (searchVarDec(auxSymTab, removeId(raiz->filho->irmao->tag)) == 0)//if var has not been declared yet
	    insertInTable(auxSymTab, createSymbolTable(removeId(raiz->filho->irmao->tag), lowerCase(raiz->filho->tag)));
    }
    if(aux && (strcmp(raiz->tag, "Call") != 0))
        analiseFuncBody(raiz->filho, symTab, auxSymTab);
    analiseFuncBody(raiz->irmao, symTab, auxSymTab);
}

int searchVarDec(table symTab, char* dec) {
    while(symTab != NULL && strcmp("", symTab->tag) != 0 && strcmp(dec, symTab->tag) != 0)
	symTab = symTab->next;
    if(symTab != NULL && strcmp("", symTab->tag) != 0)
	return 1;
    return 0;
}


int searchFuncDec(gTable symTab, char* tagValue, node raiz) {//return 1 if already defined, 2 if error, 0 if not existant INCOMPLETE
    while (symTab != NULL && strcmp(tagValue, symTab->tag) != 0){
    	symTab = symTab->next;
    }
    if (symTab == NULL) return 0;
    return 1;
}

void analiseFuncDec(node raiz, gTable symTab, table auxSymTab) {//raiz é FuncDecl
    char *aux;
    char *auxType;
    table aux1;
    aux = removeId(raiz->filho->filho->tag);
    if (raiz->filho->filho->irmao->irmao != NULL){	
	aux1 = getParamList(raiz->filho->filho->irmao->irmao);
	auxType = lowerCase(raiz->filho->filho->irmao->tag);
    } else { 
	aux1 = getParamList(raiz->filho->filho->irmao);
	auxType = strdup("none");
    }    
    insertGTable(symTab, aux, auxType, aux1, 'n');
    while(auxSymTab->next != NULL) auxSymTab = auxSymTab->next;
    auxSymTab->next = createSymbolTable("", "");
    auxSymTab->next->param = strdup(aux);
    free(aux);
    free(auxType);
}

table getParamList(node raiz) { //raiz é FuncParams
    table aux, init;
    if (raiz->filho != NULL){
	aux = createSymbolTable(removeId(raiz->filho->filho->irmao->tag), lowerCase(raiz->filho->filho->tag));
	init = aux;
    }else {
	return createSymbolTable("", "");
    }
    raiz = raiz->filho; //raiz é ParamDecl
    while(raiz->irmao != NULL){
	raiz = raiz->irmao;
	aux->next = createSymbolTable(removeId(raiz->filho->irmao->tag), lowerCase(raiz->filho->tag));
	aux = aux->next;
    }
    return init;
}

char* removeId(char* id) {
    char* aux = (char*)malloc((strlen(id) - 3) * sizeof(char));;
    strncpy(aux, id + 3, (strlen(id) - 4) * sizeof(char));
    *(aux + strlen(id) - 4) = '\0';
    return aux;
}


void printGTable(gTable raiz) {
    
    if(raiz != NULL) {
	printf("%s\t\t", raiz->tag);
	if (raiz->isVar == 'n')//if table header
	    printf("(");
	if(raiz->params)
       	    printParams(raiz->params);
	if (raiz->isVar == 'n')
            printf(")\t");
	printf("%s", raiz->type);
        
	
        printf("\n");    
        printGTable(raiz->next);
        free(raiz->type);
        free(raiz->tag);
        free(raiz);
    }
}

void printParams(table param) {
    if(param) {
        printf("%s", param->type);
        if(param->next) {
            printf(",");
        }
        printParams(param->next);
        free(param->tag);
        free(param->type);
        free(param);
    }
}

void printTable(table raiz) {
    if(raiz != NULL) {
        if(raiz->param == NULL || strcmp(raiz->param, "param") == 0) {
            if(strcmp(raiz->type, "") == 0) {
                printf("%s", raiz->tag);
            }
            else if(strcmp(raiz->tag, "") != 0){
                printf("%s\t\t%s", raiz->tag, raiz->type);
            }
            if(raiz->param != NULL)
                printf("\t%s", raiz->param);
            printf("\n");
        }
        printTable(raiz->next);
        free(raiz->tag);
        free(raiz->type);
        free(raiz->param);
        free(raiz);
    }
}

char* lowerCase(char* string) {
    char* aux;
    int i = 0;
    aux = strdup(string);
    while(*(aux + i)) {
        if(*(aux + i) >= 'A' && *(aux + i) <= 'Z') {
            *(aux + i) = *(aux + i) + 32;
        }
        i++;
    }
    return aux;
}
















