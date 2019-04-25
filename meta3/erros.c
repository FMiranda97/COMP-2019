#include "structs.h"

void errorLocation(int line, int col) {
    printf("Line %d, col %d: ", line, col);
}

void conflictingTypes(int line, int col, char* got, char* expected) {
    errorLocation(line, col);
    printf("Conflicting types (got %s, expected %s)\n", got, expected);
}

void invalidVoid(int line, int col) {
    errorLocation(line, col);
    printf("Invalid use of void type in declaration\n");
}

void lValue(int line, int col) {
    errorLocation(line, col);
    printf("Lvalue required\n");
}

void operatorApplication(int line, int col, char* token, char* type) {
    errorLocation(line, col);
    printf("Operator %s cannot be applied to type %s\n", token, type);
}

void operatorsApplication(int line, int col, char* token, char* type1, char* type2) {
    errorLocation(line, col);
    printf("Operator %s cannot be applied to types %s, %s\n", token, type1, type2);
}

void symbolAlreadyDefined(int line, int col, char* token) {
    errorLocation(line, col);
    printf("Symbol %s already defined\n", token);
}

void symbolNotFunction(int line, int col, char* token) {
    errorLocation(line, col);
    printf("Symbol %s is not a function\n", token);
}

void unknownSymbol(int line, int col, char* token) {
    errorLocation(line, col);
    printf("Unknown symbol %s\n", token);
}

void wrongArguments(int line, int col, char* token, int got, int expected) {
    errorLocation(line, col);
    printf("Wrong number of arguments to function %s (got %d, required %d)\n", token, got, expected);
}