%{
    /*#include "structs.h"  
	
    node root;
    char printFlag = 'Y';*/
	int yylex(void);
	void yyerror (char *s);
%}

%token SEMICOLON
%token BLANKID
%token PACKAGE
%token RETURN
%token AND
%token ASSIGN
%token STAR
%token COMMA
%token DIV
%token EQ
%token GE
%token GT
%token LBRACE
%token LE
%token LPAR
%token LSQ
%token LT
%token MINUS
%token MOD
%token NE
%token NOT
%token OR
%token PLUS
%token RBRACE
%token RPAR
%token RSQ
%token ELSE
%token FOR
%token IF
%token VAR
%token INT
%token FLOAT32
%token BOOL
%token STRING
%token PRINT
%token PARSEINT
%token FUNC
%token CMDARGS
%token ID
%token INTLIT
%token REALLIT
%token STRLIT
%token RESERVED

%left COMMA //???
%right ASSIGN
%left OR
%left AND
%left EQ NE
%left GE GT LE LT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT



/*
%union {
    char* id;
    struct _tree_node* no;
}*/

%%

Program: PACKAGE ID SEMICOLON Declarations
	;

Declarations: /*empty*/
	| Declarations VarDeclaration SEMICOLON 
	| Declarations FuncDeclaration SEMICOLON
	;

VarDeclaration: VAR VarSpec
	| VAR LPAR VarSpec SEMICOLON RPAR
	;

VarSpec: ID Ci Type
	| ID Type
	;

Ci: COMMA ID Ci  //comma id for varspec
	| COMMA ID
	;

Type: INT
	| FLOAT32
	| BOOL
	| STRING
	;

FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody 
	| FUNC ID LPAR RPAR Type FuncBody
	| FUNC ID LPAR Parameters RPAR FuncBody
	| FUNC ID LPAR RPAR FuncBody
	;

Parameters: ID Type Cit
	| ID Type
	;

Cit: Cit COMMA ID Type //comma id type for parameters
	| COMMA ID Type
	;
		
FuncBody: LBRACE VarsAndStatements RBRACE
	;

VarsAndStatements:/*empty*/
	| VarsAndStatements VarDeclaration SEMICOLON //loop interminavel?
	| VarsAndStatements Statement SEMICOLON
	| VarsAndStatements SEMICOLON
	;

Statement: ID ASSIGN Expr //statement1
	| LBRACE Ss RBRACE //statement2
	| LBRACE RBRACE
	| IF Expr LBRACE Ss RBRACE //statement3
	| IF Expr LBRACE RBRACE
	| IF Expr LBRACE Ss RBRACE ELSE LBRACE Ss RBRACE
	| IF Expr LBRACE RBRACE	ELSE LBRACE RBRACE
	| FOR Expr LBRACE Ss RBRACE //statement4
	| FOR LBRACE Ss RBRACE
	| FOR Expr LBRACE RBRACE
	| FOR LBRACE RBRACE
	| RETURN Expr//statement5	
	| RETURN
	| FuncInvocation //statement6
	| ParseArgs
	| PRINT LPAR Expr RPAR //statement7
	| PRINT LPAR STRLIT RPAR
	| error
	;

Ss: Ss Statement SEMICOLON //statement semicolon for Statements
	| Statement SEMICOLON
	;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR
	| ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR
	;

FuncInvocation: ID LPAR RPAR
	| ID LPAR Expr RPAR
	| ID LPAR Expr Ce RPAR
	| ID LPAR error RPAR
	;

Ce: Ce COMMA Expr //comma expr for funcinvocation
	| COMMA Expr
	;

Expr: Expr OR Expr //Expr1
	| Expr AND Expr
	| Expr LT Expr //Expr2
	| Expr GT Expr 
	| Expr EQ Expr 
	| Expr NE Expr 
	| Expr LE Expr 
	| Expr GE Expr 
	| Expr PLUS Expr //Expr3
	| Expr MINUS Expr 
	| Expr STAR Expr 
	| Expr DIV Expr 
	| Expr MOD Expr 
	| NOT Expr //Expr4
	| MINUS Expr 
	| PLUS Expr 
	| INTLIT //Expr5
	| REALLIT
	| ID
	| FuncInvocation
	| LPAR Expr RPAR
	| LPAR error RPAR //here or separate expression?
	;














%%
