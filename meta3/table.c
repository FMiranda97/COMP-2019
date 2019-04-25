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

void insertInTable(gTable root, char* tagValue, char* typeValue, table param) {
    while(root->next) {
        root = root->next;
    }
    root->next = createSymbolGTable(tagValue, typeValue, param);
}

int searchFuncDec(gTable symTab, char* tagValue, node root) { //procura declaracoes de funcoes e anuncia erros
    if(checkIfParamVoid(root->filho->irmao->irmao->filho)) {//parametros invalidos
        return 2;
    }
    checkIfRepeatedParams(root->filho->irmao->irmao->filho);
    while(symTab) {
        if(strcmp(tagValue, symTab->tag) == 0) {
            char*  aux1 = NULL;
            char* aux2 = NULL;

            aux1 = getFunctionType(lowerCase(root->filho->tag), getParamList(root->filho->irmao->irmao->filho)); //funcao declarada
            if(symTab->params)
                aux2 = getFunctionType(symTab->type, symTab->params); //funcao na tabela
            else aux2 = strdup(symTab->type);
            if(strcmp(aux2, aux1) != 0) { //conflicting types
                conflictingTypes(root->filho->irmao->line, root->filho->irmao->column, lowerCase(aux1), aux2);
                return 2;
            }
            free(aux1);
            free(aux2);
            return 1;
        }
        else {
            symTab = symTab->next;
        }
    }
    return 0;
}

table searchFuncDef(table root, char* tagValue) { //procura tabela de definicao de uma funcao
    char* aux = NULL;
    aux = (char*)malloc((strlen(tagValue) + 35) * sizeof(char));
    sprintf(aux, "===== Function %s Symbol Table =====", tagValue);
    while(root) {
        if(strcmp(aux, root->tag) == 0) {
            free(aux);
            return root;
        }
        else {
            root = root->next;
        }
    }
    free(aux);
    return NULL;
}

table startAuxTable(node tree, table root, char* tagValue, char* tagType) {
    char* funcName = removeId(tree->filho->irmao->tag);
    table aux = NULL;
    table aux1 = NULL;
    table params = getParamList(tree->filho->irmao->irmao->filho);
    params = removeRepeatedParams(params);
    while(root->next) {
        if(root->next->param && (strcmp(root->next->param, funcName) == 0))
            break;
        root = root->next;
    }
    if(root->next) {
        aux1 = root->next->next;
        free(root->next->param);
        free(root->next->tag);
        free(root->next->type);
        free(root->next);
    }
    root->next = createSymbolTable(tagValue, "");
    root->next->next = createSymbolTable("return", lowerCase(tagType));
    if(params) {
        aux = root->next->next;
        while(params) { //caso tenha parametros poe os na tabela
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
        root->next->next->next = createSymbolTable("", "");
        if(aux1)
            root->next->next->next->next = aux1;
    }
    root = root->next;
    free(funcName);
    return root;
}

void insertInAuxTable(table root, table node) { //insere linha na tabela de uma funcao
    while(strcmp(root->next->tag, "") != 0) {
        root = root->next;
    }
    node->next = root->next;
    root->next = node;
}

table getParamList(node root) { //cria lista ligada com todos os parametros de uma funcao
    table aux;
    table init;

    if(root->filho->irmao) {
        init = aux = createSymbolTable(removeId(root->filho->irmao->tag), lowerCase(root->filho->tag));
    }
    else {
        init = aux = createSymbolTable("", lowerCase(root->filho->tag));
    }
    while(root->irmao) {
        root = root->irmao;
        if(root->filho->irmao) {
            aux->next = createSymbolTable(removeId(root->filho->irmao->tag), lowerCase(root->filho->tag));
        }
        else {
            aux->next = createSymbolTable("", lowerCase(root->filho->tag));
        }
        aux = aux->next;
    }
    return init;
}

int checkFuncDec(node root, gTable symTab, table auxSymTab) { //verifica declaracoes para adicinar a tabela de simbolos
    if(root) {
        char* aux = NULL;
        table func = NULL, aux1 = NULL;
        int go = 1;
        if(strcmp(root->tag, "FuncDeclaration") == 0) {
            if(!searchFuncDec(symTab, removeId(root->filho->irmao->tag), root))
                analiseFuncDec(root, symTab, auxSymTab);
        }
        else if(strcmp(root->tag, "FuncDefinition") == 0) {
            aux = removeId(root->filho->irmao->tag);
            aux1 = searchFuncDef(auxSymTab, aux);
            if(!aux1) { //verifica se funcao ja foi definida (V se nao tiver sido)
                go = searchFuncDec(symTab, aux, root);
                if(!go) { //verifica se funcao ja foi declarada (V se nao tiver sido)
                    analiseFuncDec(root, symTab, auxSymTab); //cria declaracao na tabela global
                }
                if(go != 2) {
                    func = createFuncTable(root, auxSymTab); //cria definicao na tabela de simbolos
                    analiseFuncBody(root->filho->irmao->irmao->irmao, symTab, func);
                }
            }
            else { //funcao ja definida
                symbolAlreadyDefined(root->filho->irmao->line, root->filho->irmao->column, aux);
            }
        }
        else if(strcmp(root->tag, "Declaration") == 0) {
            if(!checkIfVoid(root)) {
                aux = removeId(root->filho->irmao->tag);
                if(!checkDeclaration(symTab, aux, root)) { //verifica se variavel nao esta declarada e da erros    
                    analiseDec(root, symTab);
                }
                checkDecAtribution(root, symTab, auxSymTab);
            }
        }
        else {
            free(aux);
            return 1;
        }
        free(aux);
    }
    if(strcmp(root->tag, "Call") == 0) 
        return 1;
    return 0;
}

void analiseFuncDec(node root, gTable symTab, table auxSymTab) { //cria declaracao na tabela global e marca posicao na tabela de funcoes
    char* aux;
    table aux1;
    
    aux = removeId(root->filho->irmao->tag);
    aux1 = getParamList(root->filho->irmao->irmao->filho);
    
    insertInTable(symTab, aux, lowerCase(root->filho->tag), aux1);

    while(auxSymTab->next) {
        auxSymTab = auxSymTab->next;
    }

    auxSymTab->next = createSymbolTable("", "");
    auxSymTab->next->param = strdup(aux);

    free(aux);
}

table createFuncTable(node root, table auxSymTab) {
    table func;
    char* aux = removeId(root->filho->irmao->tag);
    aux = (char*)realloc(aux, (strlen(aux) + 35) * sizeof(char));
    sprintf(aux, "===== Function %s Symbol Table =====", strdup(aux));
    func = startAuxTable(root, auxSymTab, aux, root->filho->tag);
    return func;
}

void analiseDec(node root, gTable symTab) { //poe variavel na tabela
    char* aux;

    aux = removeId(root->filho->irmao->tag);
    insertInTable(symTab, aux, lowerCase(root->filho->tag), NULL);

    free(aux);
}

void analiseDecF(node root, table symTab) { //verifica se funcao ja foi definida se nao foi define
    char* aux = NULL;
    table aux1 = NULL;
    if(!checkIfVoid(root)) {
        aux = removeId(root->filho->irmao->tag);
        if(!checkFuncVarDec(symTab, aux, root)) { //verifica se variavel da funcao ja foi definida (V se nao estiver)
            aux1 = createSymbolTable(aux, lowerCase(root->filho->tag));
            insertInAuxTable(symTab, aux1);
        }
    }
    free(aux);
}

void analiseFuncBody(node root, gTable symTab, table auxSymTab) {
    if(!root) {
        return;
    }
    
    int aux = 1;

    if(strcmp(root->tag, "Declaration") == 0) {
        analiseDecF(root, auxSymTab);
        checkDecAtribution(root, symTab, auxSymTab);
        aux = 0;
    }

    annoteTree(root, symTab, auxSymTab);
    if(aux && (strcmp(root->tag, "Call") != 0))
        analiseFuncBody(root->filho, symTab, auxSymTab);
    analiseFuncBody(root->irmao, symTab, auxSymTab);
}

int checkDecAtribution(node root, gTable symTab, table auxSymTab) { //verifica se uma atribuicao numa declaracao e valida
    if(root->filho->irmao->irmao) {
        annoteTree(root->filho->irmao->irmao, symTab, auxSymTab);
        if(strcmp(root->filho->irmao->irmao->type, "double") == 0 && strcmp(lowerCase(root->filho->tag), "double") != 0) {
            conflictingTypes(root->filho->irmao->line, root->filho->irmao->column, lowerCase(root->filho->irmao->irmao->type), lowerCase(root->filho->tag));
            return 0;
        }
    }
    return 1;
}

void printGTable(gTable root) {
    if(root) {
        if(strcmp(root->type, "") == 0) {
            printf("%s", root->tag);
        }
        else if(strcmp(root->tag, "") != 0){
            printf("%s\t%s", root->tag, root->type);
        }
        if(root->params) {
            printf("(");
            printParams(root->params);
            printf(")");
        }
        printf("\n");    
        printGTable(root->next);
        free(root->type);
        free(root->tag);
        free(root);
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

void printTable(table root) {
    if(root) {
        if(!(root->param && strcmp(root->param, "param") != 0)) {
            if(strcmp(root->type, "") == 0) {
                printf("%s", root->tag);
            }
            else if(strcmp(root->tag, "") != 0){
                printf("%s\t%s", root->tag, root->type);
            }
            if(root->param)
                printf("\t%s", root->param);
            printf("\n");
        }
        printTable(root->next);
        free(root->tag);
        free(root->type);
        free(root->param);
        free(root);
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

int checkDeclaration(gTable symTab, char* dec, node root) { //verifica se variavel ja foi declarada globalmente
    if(symTab == NULL) {
        return 0;
    }
    else if(strcmp(dec, symTab->tag) == 0) { //funcao variavel ja definida
        if(symTab->params || strcmp(symTab->type, lowerCase(root->filho->tag)) != 0)
            symbolAlreadyDefined(root->filho->irmao->line, root->filho->irmao->column, dec);
        return 1;
    }
    else {
        return checkDeclaration(symTab->next, dec, root);
    }
}

int checkFuncVarDec(table symTab, char* dec, node root) {
    if(symTab == NULL || strcmp("", symTab->tag) == 0) {
        return 0;
    }
    else if(strcmp(dec, symTab->tag) == 0) {
        symbolAlreadyDefined(root->filho->irmao->line, root->filho->irmao->column, dec);
        return 1;
    }
    else {
        return checkFuncVarDec(symTab->next, dec, root);
    }
}

char* removeId(char* id) {
    char* aux = (char*)malloc((strlen(id) - 3) * sizeof(char));;
    strncpy(aux, id + 3, (strlen(id) - 4) * sizeof(char));
    *(aux + strlen(id) - 4) = '\0';
    return aux;
}

int checkIfVoid(node root) { //verifica se e void
    if(strcmp(root->filho->tag, "Void") == 0) {
        invalidVoid(root->filho->irmao->line, root->filho->irmao->column);
        return 1;
    }   
    return 0;
}

int checkIfParamVoid(node root) { //verifica se algum parametro e void
    int nrParams = 0;
    while(root) {
        if(strcmp(root->filho->tag, "Void") == 0 && (nrParams || root->irmao || root->filho->irmao)) {
            invalidVoid(root->filho->line, root->filho->column);
            return 1;
        } 
        nrParams++; 
        root = root->irmao;
    } 
    return 0;
}

void checkIfRepeatedParams(node root) { //verifica parametros repetidos
    node aux1 = root;
    node aux2 = root;
    int nrParams = 0, i;
    while(aux1) {
        if(aux1->filho->irmao) {
            for(i = 0; aux2 && (i < nrParams); i++) {
                if(aux2->filho->irmao && strcmp(aux1->filho->irmao->tag, aux2->filho->irmao->tag) == 0) {
                    symbolAlreadyDefined(aux1->filho->irmao->line, aux1->filho->irmao->column, removeId(aux1->filho->irmao->tag));
                }
                aux2 = aux2->irmao;
            }
        }
        aux2 = root;
        nrParams++;
        aux1 = aux1->irmao;
    } 
}

table removeRepeatedParams(table root) { //remove parametros repetidos
    table aux1 = root;
    table aux2 = root;
    int nrParams = 0, i;
    while(aux1) {
        if(strcmp(aux1->tag, "") != 0) {
            for(i = 0; aux2 && (i < nrParams); i++) {
                if(strcmp(aux2->tag, "") != 0 && strcmp(aux1->tag, aux2->tag) == 0) {
                    for(; i < nrParams - 1; i++) {
                        aux2 = aux2->next;
                    }
                    aux2->next = aux1->next;
                    aux1 = aux2->next;
                    break;
                }
                aux2 = aux2->next;
            }
        }
        aux2 = root;
        nrParams++;
        if(aux1)
            aux1 = aux1->next; 
    }
    return root;
}

char* getFunctionType(char* type, table symTab) { // cria uma string com o tipo da funcao
    char* aux = (char*)malloc((strlen(type) + 3) * sizeof(char));
    sprintf(aux, "%s(", type);
    while(symTab) {
        aux = (char*)realloc(aux, (strlen(aux) + strlen(symTab->type) + 3) * sizeof(char));
        sprintf(aux, "%s%s", aux, symTab->type);
        if(symTab->next) {
            sprintf(aux, "%s,", aux);
        }
        symTab = symTab->next;
    }
    sprintf(aux, "%s)", aux);
    return aux;
}

void annoteFuncBody(node root, gTable symTab, table auxSymTab) {
    if(!root)
        return;

    annoteTree(root, symTab, auxSymTab);
    
    annoteFuncBody(root->filho, symTab, auxSymTab);
    annoteFuncBody(root->irmao, symTab, auxSymTab);
}

void checkSemantics(node root, gTable symTab, table auxSymTab) {
    int aux;
    if(!root) {
        return;       
    }
    aux = checkFuncDec(root, symTab, auxSymTab);
    annoteTree(root, symTab, auxSymTab);
    if(aux)
        checkSemantics(root->filho, symTab, auxSymTab);
    checkSemantics(root->irmao, symTab, auxSymTab);
}
