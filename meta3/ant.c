#include "structs.h"

void annoteTree(node raiz, gTable symTab, table funcTable) {
    int aux;
    if(raiz != NULL){
	if(strncmp(raiz->tag, "Id", 2) == 0){
	    analiseVarId(raiz, symTab, funcTable);
	}else if(strcmp(raiz->tag, "Call") == 0){
	    aux = analiseFuncId(raiz->filho, symTab);
	    if(aux == 0)
		raiz->type = findFuncType(removeId(raiz->filho->tag), symTab);
	    else if(aux == 2)
		erroCannotFindSymbolCall(raiz->filho);
	}else if(isLogical(raiz->tag)){
	    raiz->type = strdup("bool");
	}else if(!strncmp(raiz->tag, "StrLit", 6)){
	    raiz->type = strdup("string");
	}else if(!strncmp(raiz->tag, "IntLit", 6)){
	    raiz->type = strdup("int");
	}else if(!strncmp(raiz->tag, "RealLit", 7)){
	    raiz->type = strdup("float32");
	}else if(!strcmp(raiz->tag, "Minus") || !strcmp(raiz->tag, "Plus")){
	    annoteTree(raiz->filho, symTab, funcTable);
	    raiz->type = strdup(raiz->filho->type);
	}else if(!strcmp(raiz->tag, "Not")){
	    raiz->type = strdup("bool");
	}else if(isOperator(raiz->tag)){
	    annoteOperator(raiz, symTab, funcTable);
	}else if(!strcmp(raiz->tag, "Assign") || !strcmp(raiz->tag, "ParseArgs")){
	    annoteAssign(raiz, symTab, funcTable);
	}
    }
}

void annoteAssign(node raiz, gTable symTab, table funcTable){
    node operand1 = raiz->filho;
    node operand2 = raiz->filho->irmao;
    annoteTree(operand1, symTab, funcTable);
    annoteTree(operand2, symTab, funcTable);
    raiz->type = operand1->type;
}

void annoteOperator(node raiz, gTable symTab, table funcTable){
    node operand1 = raiz->filho;
    node operand2 = raiz->filho->irmao;
    annoteTree(operand1, symTab, funcTable);
    annoteTree(operand2, symTab, funcTable);
    if(strcmp(operand1->type, operand2->type) == 0){//se são iguais, problema resolvido
	raiz->type = operand1->type;
    }else if(strcmp(operand1->type, "undef") == 0 || strcmp("undef", operand2->type) == 0){//se um é undef, resultado também é
	raiz->type = strdup("undef");
    }else if(strcmp(operand1->type, "string") == 0 || strcmp("string", operand2->type) == 0){//se uma é string e não são iguais, undef
	raiz->type = strdup("undef");
    }else if(strcmp(operand1->type, "float32") == 0 || strcmp("float32", operand2->type) == 0){
	raiz->type = strdup("float32");
    }else if(strcmp(operand1->type, "int") == 0 || strcmp("int", operand2->type) == 0){
	raiz->type = strdup("int");
    }else if(strcmp(operand1->type, "bool") == 0 || strcmp("bool", operand2->type) == 0){
	raiz->type = strdup("bool");
    }else raiz->type = strdup("undef");
}

char isOperator(char* string){
    if(!strcmp(string, "Add") || !strcmp(string, "Sub") || !strcmp(string, "Mul") || !strcmp(string, "Div") || !strcmp(string, "Mod"))
	return 1;
    return 0;
}

char isLogical(char* string){//returns 1 if is logical operator, 0 if not
    if(!strcmp(string, "Or") || !strcmp(string, "And") || !strcmp(string, "Eq") || !strcmp(string, "Ne") || !strcmp(string, "Lt") || !strcmp(string, "Gt") || !strcmp(string, "Le") || !strcmp(string, "Ge") || !strcmp(string, "Not"))
	return 1;
    return 0;
}

char* findFuncType(char* funcId, gTable symTab){
    while(symTab != NULL && strcmp(symTab->tag, funcId) != 0)
	symTab = symTab->next;
    if(symTab != NULL && strcmp(symTab->type, "none") != 0) return strdup(symTab->type);
    return NULL;
}

int analiseFuncId(node raiz, gTable symTab) { //verifica se id e uma funcao e retorna 0 e anota se for, retorna 1 se variavel global, retorna 2 se nao existe
    char* aux;
    aux = removeId(raiz->tag);
    
    while(symTab != NULL) {
        if(strcmp(symTab->tag, aux) == 0) {
            if(symTab->params != NULL) { //como tem parametros e uma funcao
                if(raiz->type == NULL) //anota se nao tiver sido anotada anteriormente
                    raiz->type = annoteFuncParams(symTab);
                return 0;
            }
            else { //nao tem parametros e uma variavel
                free(aux);
                return 1;
            }
        }
        symTab = symTab->next;
    }
    free(aux);
    return 2;
}   


void analiseVarId(node raiz, gTable symTab, table funcTable) { //procura declaracao de variavel
    char* aux;
    aux = removeId(raiz->tag);

    while(funcTable != NULL) {
        if(strcmp(funcTable->tag, aux) == 0) {
            raiz->type = strdup(funcTable->type);
            free(aux);
            return;
        }
        funcTable = funcTable->next;
    }

    while(symTab != NULL) {
        if(strcmp(symTab->tag, aux) == 0) {
            if(symTab->params != NULL)
                raiz->type = annoteFuncParams(symTab);
            else 
                raiz->type = strdup(symTab->type);
            free(aux);
            return;
        }
        symTab = symTab->next;
    }
    free(aux);
    //id nao declarado
    raiz->type = strdup("undef"); //anota o no como undef
}

char* annoteFuncParams(gTable symTab) { //anota parametros de uma funcao
    char* aux;
    table auxParam = symTab->params;
    aux = (char*)malloc((strlen(symTab->type) + 2) * sizeof(char));
    sprintf(aux, "(");
    while(auxParam) {
        aux = (char*)realloc(aux, (strlen(aux) + strlen(auxParam->type) + 4) * sizeof(char));
        if(auxParam->next) {
        sprintf(aux, "%s%s,", aux, auxParam->type);
        }
        else {
            sprintf(aux, "%s%s", aux, auxParam->type);
        }
        auxParam = auxParam->next;
    }
    sprintf(aux, "%s)", aux);
    
    return aux;
}

void printAnnotedTree(node raiz, int level) {
    int aux;
    if(raiz == NULL) {
        return;
    }
    else {
        for(aux = 0; aux < level; aux++) {
            printf("..");
        }
        if(raiz->type) {
            printf("%s - %s\n", raiz->tag, raiz->type);
        }
        else {
            printf("%s\n", raiz->tag);
        }
    }
    printAnnotedTree(raiz->filho, level + 1);
    printAnnotedTree(raiz->irmao, level);

    free(raiz->tag);
    free(raiz->type);
    free(raiz->filho);
    free(raiz->irmao);
}
