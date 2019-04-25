#include "structs.h"

char* checkVarType(char* string) {
    char* aux = NULL;
    if(!string)
        return NULL;
    if((strncmp(string, "IntLit", 6) == 0) || (strncmp(string, "int", 3) == 0)) {
        aux = strdup("int");
    }
    else if(strncmp(string, "ChrLit", 6) == 0) {
        aux = strdup("int");
    }
    else if(strncmp(string, "RealLit", 7) == 0 || strncmp(string, "double", 6) == 0) {
        aux = strdup("double");
    }
    else if(strncmp(string, "char", 4) == 0) {
        aux = strdup("char");
    }
    else if(strncmp(string, "void", 4) == 0) {
        aux = strdup("void");
    }
    else if(strncmp(string, "short", 5) == 0) {
        aux = strdup("short");
    }
    else if(strcmp(string, "undef") == 0) {
        aux = strdup("undef");
    }
    if(aux)
        return aux;
    return NULL;
}

void annoteTree(node root, gTable symTab, table auxSymTab) {
    if(root && !root->type) {
        if(checkIfId(root->tag)) {
            analiseVarId(root, symTab, auxSymTab);
        }
        else if(strcmp(root->tag, "Call") == 0) {
            annoteTree(root->filho, symTab, auxSymTab);
            if(strcmp(root->filho->type, "undef") != 0) {
                if(!analiseFuncId(root->filho, root->filho->tag, symTab)) {
                    node aux = root->filho->irmao;
                    while(aux) {
                        annoteTree(aux, symTab, auxSymTab);
                        aux = aux->irmao;
                    }
                    analiseFuncCall(root->filho, root->filho->tag, symTab);
                    free(aux);
                }
                root->type = checkVarType(root->filho->type);
            }
            else {
                root->type = strdup("undef");
            }
        }
        else if(strcmp(root->tag, "Store") == 0) {
            annoteTree(root->filho, symTab, auxSymTab);
            annoteTree(root->filho->irmao, symTab, auxSymTab);
            if(checkIfFunction(root->filho->type)) {
                operatorsApplication(root->line, root->column, getOperator(root->tag), root->filho->type, root->filho->irmao->type);
                root->type = strdup("undef");
            }
            else {
                analiseStore(root);
                root->type = checkVarType(root->filho->type);
            }
        }
        else if(checkIfOperation(root->tag)) {
            //printf("-->%s\n", root->tag);
            annoteTree(root->filho, symTab, auxSymTab);
            annoteTree(root->filho->irmao, symTab, auxSymTab);
            checkOperationType(root, symTab, auxSymTab);
            //printf("--->%s = %s\n", root->tag, root->type);
        }
        else if(checkIfSpecialLogicalOperation(root->tag)) {
            annoteTree(root->filho, symTab, auxSymTab);
            annoteTree(root->filho->irmao, symTab, auxSymTab);
            if(root->filho->irmao && (strcmp(root->filho->type, "undef") == 0 || strcmp(root->filho->irmao->type, "undef") == 0)) {
                operatorsApplication(root->line, root->column, getOperator(root->tag), root->filho->type, root->filho->irmao->type);
                if(strncmp(root->tag, "BitWise", 7) == 0)
                    root->type = strdup("undef");
            }
            else if(root->filho->irmao && ((strcmp(root->filho->type, "double") == 0 || strcmp(root->filho->irmao->type, "double") == 0) || checkIfFunction(root->filho->type) || checkIfFunction(root->filho->irmao->type))) {
                operatorsApplication(root->line, root->column, getOperator(root->tag), root->filho->type, root->filho->irmao->type);
            }
            else if(strcmp(root->filho->type, "undef") == 0 || strcmp(root->filho->type, "double") == 0 || checkIfFunction(root->filho->type)) {
                operatorApplication(root->line, root->column, getOperator(root->tag), root->filho->type);
            }
            if(!root->type)
                root->type = strdup("int");
        }
        else if(checkIfLogicalOperation(root->tag)) {
            annoteTree(root->filho, symTab, auxSymTab);
            annoteTree(root->filho->irmao, symTab, auxSymTab);
            if(root->filho->irmao && ((strcmp(root->filho->type, "undef") == 0 || strcmp(root->filho->irmao->type, "undef") == 0) || checkIfFunction(root->filho->type) || checkIfFunction(root->filho->irmao->type))) {
                operatorsApplication(root->line, root->column, getOperator(root->tag), root->filho->type, root->filho->irmao->type);
            }
            else if(strcmp(root->filho->type, "undef") == 0 || checkIfFunction(root->filho->type)) {
                operatorApplication(root->line, root->column, getOperator(root->tag), root->filho->type);
            }
            if(!root->type)
                root->type = strdup("int");
        }
        else if(strcmp(root->tag, "If") == 0 || strcmp(root->tag, "While") == 0) {
            annoteTree(root->filho, symTab, auxSymTab);
            if(strcmp(root->filho->type, "undef") == 0 || strcmp(root->filho->type, "double") == 0 || checkIfFunction(root->filho->type)) {
                conflictingTypes(root->filho->line, root->filho->column, root->filho->type, "int");
            }
        }
        else if(strcmp(root->tag, "Return") == 0) {
            annoteTree(root->filho, symTab, auxSymTab);
            checkReturn(root, root->filho->type, auxSymTab);
            
        }
        else {
            root->type = checkVarType(root->tag);
        }
    }       
}

void analiseStore(node root) {
    /*while(root->filho && checkIfOperation(root->filho->tag)) {
        root = root->filho;
    }*/
    if(!checkIfId(root->filho->tag)) { //verifica se nao e id onde vamos guardar
        lValue(root->filho->line, root->filho->column);
        return;
    }
    else if(validateConversion(root)) { // <-- mal muito mal
        return;
    }
    else {
        return;
    }
}

void analiseFuncCall(node root, char* id, gTable symTab) { //verifica validade de uma call
    int got = 0;
    int expected = getFunctionNrParams(symTab, removeId(id));
    node aux = root->irmao;
    while(aux) { //verifica quantos argumentos recebeu
        got++;
        aux = aux->irmao;
    }
    if(got != expected) {
        wrongArguments(root->line, root->column, removeId(root->tag), got, expected);
        return;
    }
    int rem;
    aux = root->irmao;
    char* token = NULL;
    char* aux1 = NULL;
    char* params = strdup(root->type);
    rem = strlen(checkVarType(params));
    aux1 = (char*)malloc((strlen(params) + 1) * sizeof(char));
    strncpy(aux1, params + rem + 1, strlen(params) - 2);
    *(aux1 + strlen(params) - rem - 2) = '\0';
    token = strtok(aux1, ",");
    while(token && aux) {
        if((strcmp(aux->type, "double") == 0 && strcmp("double", token) != 0)
        || (strcmp(aux->type, "void") == 0 && strcmp("void", token) != 0)) {
            if(strcmp(aux->tag, "Call") == 0) {
                conflictingTypes(aux->filho->line, aux->filho->column, aux->type, token);
            }
            else
                conflictingTypes(aux->line, aux->column, aux->type, token);
        }
        token = strtok(NULL, ",");
        aux = aux->irmao;
    }
    free(aux1);
}

int analiseFuncId(node root, char* id, gTable symTab) { //verifica se id e uma funcao e retorna 0 e anota se for 
    char* aux;
    aux = removeId(id);
    
    while(symTab) {
        if(strcmp(symTab->tag, aux) == 0) {
            if(symTab->params) { //como tem parametros e uma funcao
                if(!root->type) //anota se nao tiver sido anotada anteriormente
                    root->type = annoteFuncParams(symTab);
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
    return 1;
}   

void analiseVarId(node root, gTable symTab, table auxSymTab) { //procura declaracao de variavel
    char* aux;
    aux = removeId(root->tag);

    while(auxSymTab) {
        if(strcmp(auxSymTab->tag, aux) == 0) {
            root->type = strdup(auxSymTab->type);
            free(aux);
            return;
        }
        auxSymTab = auxSymTab->next;
    }

    while(symTab) {
        if(strcmp(symTab->tag, aux) == 0) {
            if(symTab->params)
                root->type = annoteFuncParams(symTab);
            else 
                root->type = strdup(symTab->type);
            free(aux);
            return;
        }
        symTab = symTab->next;
    }
    free(aux);
    //id nao declarado
    unknownSymbol(root->line, root->column, removeId(root->tag)); //erro unknown symbol
    root->type = strdup("undef"); //anota o no como undef
}

char* annoteFuncParams(gTable symTab) { //anota parametros de uma funcao
    char* aux;
    table auxParam = symTab->params;
    aux = (char*)malloc((strlen(symTab->type) + 2) * sizeof(char));
    sprintf(aux, "%s(", symTab->type);
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

int checkIfOperation(char* string) {
    if((strcmp(string, "Mul") == 0) || (strcmp(string, "Add") == 0) 
    || (strcmp(string, "Sub") == 0) || (strcmp(string, "Minus") == 0) 
    || (strcmp(string, "Div") == 0) || (strcmp(string, "Plus") == 0)
    || (strcmp(string, "Comma") == 0)) {
        return 1;
    }
    else {
        return 0;
    }
}

void checkOperationType(node root, gTable symTab, table auxSymTable) { //verifica tipo de operacao
    char* aux1 = NULL;
    char* aux2 = NULL;

    aux1 = checkVarType(root->filho->type);     
    if(!aux1)
        return;
    if(root->filho->irmao) {
        aux2 = checkVarType(root->filho->irmao->type);
        if(!aux2)
            return;
        
        if (strcmp(aux1, "undef") == 0 || strcmp(aux2, "undef") == 0) {
            root->type = strdup("undef");
            operatorsApplication(root->line, root->column, getOperator(root->tag), root->filho->type, root->filho->irmao->type);
        }
        else if(checkIfFunction(root->filho->type) || checkIfFunction(root->filho->irmao->type)) {
            root->type = strdup("undef");
            operatorsApplication(root->line, root->column, getOperator(root->tag), root->filho->type, root->filho->irmao->type);
        }
        else if((strcmp(root->tag, "Comma") == 0)) {
            root->type = strdup(aux2);
        }
        else if(strcmp(aux1, "double") == 0 || strcmp(aux2, "double") == 0) {
            root->type = strdup("double");
        }
        else if (strcmp(aux1, "int") == 0 || strcmp(aux2, "int") == 0) {
            root->type = strdup("int");
        }
        else if (strcmp(aux1, "short") == 0 || strcmp(aux2, "short") == 0) {
            root->type = strdup("short");
        }
        else {
            root->type = strdup("char");
        }
    }
    else { //operadores unarios
        if(strcmp(root->filho->type, "undef") == 0 || checkIfFunction(root->filho->type)) {
            root->type = strdup("undef");
            operatorApplication(root->line, root->column, getOperator(root->tag), root->filho->type);
        }
        else
            root->type = strdup(aux1);
    }
    free(aux1);
    free(aux2);
}

int checkIfLogicalOperation(char* string) {
    if((strcmp(string, "Ge") == 0) || (strcmp(string, "Eq") == 0) 
    || (strcmp(string, "Ne") == 0) || (strcmp(string, "Lt") == 0) 
    || (strcmp(string, "Gt") == 0) || (strcmp(string, "Le") == 0)) {
        return 1;
    }
    else {
        return 0;
    }
}

int checkIfSpecialLogicalOperation(char* string) {
    if((strcmp(string, "And") == 0) || (strcmp(string, "Or") == 0)
    || (strcmp(string, "Not") == 0) || (strcmp(string, "Mod") == 0)
    || (strcmp(string, "BitWiseOr") == 0) 
    || (strcmp(string, "BitWiseXor") == 0) || (strcmp(string, "BitWiseAnd") == 0)) {
        return 1;
    }
    else {
        return 0;
    }
}

int checkIfId(char* string) { //verifica se e uma id 1 se for 0 se nao for
    if(strncmp(string, "Id", 2) == 0) {
        return 1;
    }
    return 0;
}

void printAnnotedTree(node root, int level) {
    int aux;
    if(root == NULL) {
        return;
    }
    else {
        for(aux = 0; aux < level; aux++) {
            printf("..");
        }
        if(root->type) {
            printf("%s - %s\n", root->tag, root->type);
        }
        else {
            printf("%s\n", root->tag);
        }
    }
    printAnnotedTree(root->filho, level + 1);
    printAnnotedTree(root->irmao, level);

    free(root->tag);
    free(root->type);
    free(root->filho);
    free(root->irmao);
}

int getFunctionNrParams(gTable symTab, char* funcName) { //retorna quantos parametros uma funcao espera receber
    int aux = 0; //variavel para conter nr de parametros esperados
    table aux1 = NULL;
    while(symTab) {
        if(strcmp(symTab->tag, funcName) == 0) {
            aux1 = symTab->params;
            while(aux1) {
                if(strcmp(aux1->type, "void") != 0)
                    aux++;
                aux1 = aux1->next;
            }
            return aux;
        }
        symTab = symTab->next;
    }
    return aux;
}

char* getOperator(char* operatorTag) {
    char* aux = NULL;
    if(strcmp(operatorTag, "Comma") == 0) {
        aux = strdup(",");
    }
    else if(strcmp(operatorTag, "Plus") == 0 || strcmp(operatorTag, "Add") == 0) {
        aux = strdup("+");
    }
    else if(strcmp(operatorTag, "Minus") == 0 || strcmp(operatorTag, "Sub") == 0) {
        aux = strdup("-");
    }
    else if(strcmp(operatorTag, "Div") == 0) {
        aux = strdup("/");
    }
    else if(strcmp(operatorTag, "Mod") == 0) {
        aux = strdup("%");
    }
    else if(strcmp(operatorTag, "Not") == 0) {
        aux = strdup("!");
    }
    else if(strcmp(operatorTag, "Mul") == 0) {
        aux = strdup("*");
    }
    else if(strcmp(operatorTag, "BitWiseOr") == 0) {
        aux = strdup("|");
    }
    else if(strcmp(operatorTag, "BitWiseXor") == 0) {
        aux = strdup("^");
    }
    else if(strcmp(operatorTag, "BitWiseAnd") == 0) {
        aux = strdup("&");
    }
    else if(strcmp(operatorTag, "And") == 0) {
        aux = strdup("&&");
    }
    else if(strcmp(operatorTag, "Or") == 0) {
        aux = strdup("||");
    }
    else if(strcmp(operatorTag, "Eq") == 0) {
        aux = strdup("==");
    }
    else if(strcmp(operatorTag, "Gt") == 0) {
        aux = strdup(">");
    }
    else if(strcmp(operatorTag, "Lt") == 0) {
        aux = strdup("<");
    }
    else if(strcmp(operatorTag, "Ge") == 0) {
        aux = strdup(">=");
    }
    else if(strcmp(operatorTag, "Le") == 0) {
        aux = strdup("<=");
    }
    else if(strcmp(operatorTag, "Ne") == 0) {
        aux = strdup("!=");
    }
    else if(strcmp(operatorTag, "Store") == 0) {
        aux = strdup("=");
    }
    return aux;
}

int validateConversion(node root) { //verifica se uma conversao e valida
    if(strcmp(root->filho->irmao->type, "double") == 0 && strcmp(root->filho->type, "double") != 0) {
        operatorsApplication(root->line, root->column, getOperator(root->tag), lowerCase(root->filho->type), lowerCase(root->filho->irmao->type));
        return 1;
    }
    else {
        return 0;
    }
}

int checkIfFunction(char* type) {
    if(strlen(type) > 6) {
        return 1;
    }
    return 0;
}

void checkReturn(node root, char* got, table symTab) {
    char* expected = NULL;
    if(!got)
        got = strdup("void");
    while(symTab) {
        if(strcmp(symTab->tag, "return") == 0) {
            expected = strdup(symTab->type);
            break;
        }
        symTab = symTab->next;
    }
    if(checkIfFunction(got) || (strcmp(got, "double") == 0 && strcmp(expected, "double") != 0) || (strcmp(got, "void") != 0 && strcmp(expected, "void") == 0)) {
        conflictingTypes(root->filho->line, root->filho->column, got, expected);
    }
    else if(strcmp(got, "void") == 0 && strcmp(expected, "void") != 0) {
        conflictingTypes(root->line, root->column, got, expected);
    }
}
    
