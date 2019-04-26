#include "structs.h"

gTable startTable() {
    gTable symTab;
    symTab = createSymbolGTable("===== Global Symbol Table =====", "", NULL);
    return symTab;
}

gTable createSymbolGTable(char* tagValue, char* typeValue, table fParams) {
    gTable aux = (gTable)malloc(sizeof(g_sym_table));
    aux->tag = (char*)malloc((strlen(tagValue) + 1) * sizeof(char));
    strcpy(aux->tag, tagValue);
    aux->type = (char*)malloc((strlen(typeValue) + 1) * sizeof(char));
    strcpy(aux->type, typeValue);
    aux->params = fParams;
    aux->next = NULL;
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

void insertInTable(gTable raiz, char* tagValue, char* typeValue, table param) {
    while(raiz->next != NULL) {
        raiz = raiz->next;
    }
    raiz->next = createSymbolGTable(tagValue, typeValue, param);
}

void checkSemantics(node raiz, gTable symTab, table auxSymtab) {
    int aux;
    if (raiz == NULL) return;
    aux = checkFuncDec(raiz, symTab, auxSymtab);
    if(aux != 1) checkSemantics(raiz->filho, symTab, auxSymtab);
    else checkSemantics(raiz->irmao, symTab, auxSymtab);
}

int checkFuncDec(node raiz, gTable symTab, table auxSymTab){
    /*char *aux = NULL;
    table func = NULL;
    int go = 1;*/
    if (strcmp(raiz->tag, "FuncDecl") == 0) {
	if(searchFuncDec(symTab, removeId(raiz->filho->filho->tag), raiz) == 0) {
	    analiseFuncDec(raiz, symTab, auxSymTab);
	}
	return 1;
    }
    return 0;
}


//return 1 if already defined, 2 if error, 0 if not existant INCOMPLETE
int searchFuncDec(gTable symTab, char* tagValue, node raiz) {
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
    insertInTable(symTab, aux, auxType, aux1);
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
	aux->next = createSymbolTable(removeId(raiz->filho->filho->irmao->tag), lowerCase(raiz->filho->filho->tag));
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
	printf("%s\t", raiz->tag);
        /*if(strcmp(raiz->type, "") == 0) {
            printf("%s", raiz->tag);
        }
        else if(strcmp(raiz->tag, "") != 0){
            printf("%s\t%s", raiz->tag, raiz->type);
        }*/
	if (strncmp("===== ", raiz->tag, 6) != 0){
	    printf("(");
	    if(raiz->params)
        	printParams(raiz->params);
            printf(")\t");
	    printf("%s", raiz->type);
	}
        
	
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
    if(raiz) {
        if(!(raiz->param && strcmp(raiz->param, "param") != 0)) {
            if(strcmp(raiz->type, "") == 0) {
                printf("%s", raiz->tag);
            }
            else if(strcmp(raiz->tag, "") != 0){
                printf("%s\t%s", raiz->tag, raiz->type);
            }
            if(raiz->param)
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
















