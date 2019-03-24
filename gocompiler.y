%{
    #include "structs.h"  
    node root;
    int print = 1;
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
%token <value> ID
%token <value> INTLIT
%token <value> REALLIT
%token <value> STRLIT
%token <value> RESERVED


%union {
    char* value;
    struct _tree_node* no;
}


%type <no> Program
%type <no> Declarations
%type <no> VarDeclaration
%type <no> VarSpec
%type <no> Ci
%type <no> Type
%type <no> FuncDeclaration
%type <no> Parameters
%type <no> Cit
%type <no> FuncBody
%type <no> VarsAndStatements
%type <no> Statement
%type <no> Ss
%type <no> ParseArgs
%type <no> FuncInvocation
%type <no> Ce
%type <no> Expr


%left COMMA //???
%right ASSIGN
%left OR
%left AND
%left EQ NE
%left GE GT LE LT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT

%%

Program: PACKAGE ID SEMICOLON Declarations	{if(flag == 't'){ root = createNode("Program"); addChild(root, $4); $$ = root; if(print == 1) printTree(root, 0); else freeTree(root);}; }
	| PACKAGE ID SEMICOLON			{if(flag == 't'){$$ = createNodeTerminal("Id", $2); free($2);};}
	;

Declarations: Declarations VarDeclaration SEMICOLON 	{if(flag == 't'){addSibling($1, $2); $$ = $1;};}
	| Declarations FuncDeclaration SEMICOLON	{if(flag == 't'){addSibling($1, $2); $$ = $1;};}
	| VarDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	| FuncDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	;

VarDeclaration: VAR VarSpec				{if(flag == 't'){$$ = createNode("VarDecl"); addChild($$, $2);};} //??
	| VAR LPAR VarSpec SEMICOLON RPAR		{if(flag == 't'){$$ = createNode("VarDecl"); addChild($$, $3);};}
	;

VarSpec: ID Ci Type					{if(flag == 't'){addSibling($$, $2); $$ = $3; addSibling($$, createNodeTerminal("Id", $1)); free($1);}; }
	| ID Type					{if(flag == 't'){$$ = $2; addSibling($$, createNodeTerminal("Id", $1)); free($1);}; } //segfault here
	;

//comma id for varspec
Ci: COMMA ID Ci  					{if(flag == 't'){$$ = createNodeTerminal("ID", $2); addSibling($$, $3);};}			
	| COMMA ID					{if(flag == 't'){$$ = createNodeTerminal("ID", $2); };}
	;

Type: INT						{if(flag == 't'){$$ = createNode("Int");};}
	| FLOAT32					{if(flag == 't'){$$ = createNode("Float32");};}
	| BOOL						{if(flag == 't'){$$ = createNode("Bool");};}
	| STRING					{if(flag == 't'){$$ = createNode("String");};}
	;


FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody 	{if(flag == 't'){$$ = createNode("FuncDecl"); $$->child = createNode("FuncHeader"); addChild($$->child, createNodeTerminal("Id", $2)); 											free($2); addSibling($$->child->child, $6); addSibling($$->child->child, $4); addSibling($$->child, $7);}; }
	| FUNC ID LPAR Parameters RPAR FuncBody			{if(flag == 't'){$$ = createNode("FuncDecl"); $$->child = createNode("FuncHeader"); addChild($$->child, createNodeTerminal("Id", $2)); 											free($2);  addSibling($$->child->child, $4); addSibling($$->child, $6);};}
	;

Parameters: /*empty*/						{if(flag == 't') $$ = createNode("FuncParams");}
	| ID Type Cit						{if(flag == 't'){$$ = createNode("FuncParams"); $$->child = createNode("ParamDecl"); $$->child->child = $2; 												addSibling($$->child->child, createNodeTerminal("Id", $1)); addSibling($$->child, $3);}; }
	| ID Type						{if(flag == 't'){$$ = createNode("FuncParams"); $$->child = createNode("ParamDecl"); $$->child->child = $2; 																addSibling($$->child->child, createNodeTerminal("Id", $1));}; }
	;

//comma id type for parameters
Cit: Cit COMMA ID Type 						{if(flag == 't'){$$ = createNode("ParamDecl"); $$->child = $4; addSibling($$->child, createNodeTerminal("Id", $3)); addSibling($$, $1);};}
	| COMMA ID Type						{if(flag == 't'){$$ = createNode("ParamDecl"); $$->child = $3; addSibling($$->child, createNodeTerminal("Id", $2));};}
	;
		
FuncBody: LBRACE VarsAndStatements RBRACE			{if(flag == 't'){$$ = createNode("FuncBody");};}
	| LBRACE RBRACE						{if(flag == 't'){$$ = createNode("FuncBody");};}
	;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON 		{if(flag == 't'){};}
	| VarsAndStatements Statement SEMICOLON			{if(flag == 't'){};}
	| VarsAndStatements SEMICOLON				{if(flag == 't'){};}
	| VarDeclaration SEMICOLON 				{if(flag == 't'){};}
	| Statement SEMICOLON					{if(flag == 't'){};}
	| SEMICOLON						{if(flag == 't'){};}
	;

Statement: ID ASSIGN Expr 					{if(flag == 't'){};}
	| LBRACE Ss RBRACE 					{if(flag == 't'){};}
	| LBRACE RBRACE						{if(flag == 't'){$$ = NULL;};}
	| IF Expr LBRACE Ss RBRACE 				{if(flag == 't'){};}
	| IF Expr LBRACE RBRACE					{if(flag == 't'){};}
	| IF Expr LBRACE Ss RBRACE ELSE LBRACE Ss RBRACE	{if(flag == 't'){};}
	| IF Expr LBRACE RBRACE	ELSE LBRACE RBRACE		{if(flag == 't'){};}
	| FOR Expr LBRACE Ss RBRACE 				{if(flag == 't'){};}
	| FOR LBRACE Ss RBRACE					{if(flag == 't'){};}
	| FOR Expr LBRACE RBRACE				{if(flag == 't'){};}
	| FOR LBRACE RBRACE					{if(flag == 't'){};}
	| RETURN Expr						{if(flag == 't'){};}
	| RETURN						{if(flag == 't'){};}
	| FuncInvocation 					{if(flag == 't'){};}
	| ParseArgs						{if(flag == 't'){};}
	| PRINT LPAR Expr RPAR 					{if(flag == 't'){};}
	| PRINT LPAR STRLIT RPAR				{if(flag == 't'){};}
	| error							{print = 0; if(flag == 't'){$$ = NULL;};}
	;

//statement semicolon for Statements
Ss: Ss Statement SEMICOLON 					{if(flag == 't'){};}
	| Statement SEMICOLON					{if(flag == 't'){};}
	;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR 	{if(flag == 't'){};}
	| ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR			{print = 0; if(flag == 't'){$$ = NULL;};}
	;

FuncInvocation: ID LPAR RPAR					{if(flag == 't'){};}
	| ID LPAR Expr RPAR					{if(flag == 't'){};}
	| ID LPAR Expr Ce RPAR					{if(flag == 't'){};}
	| ID LPAR error RPAR					{print = 0; if(flag == 't'){$$ = NULL;};}
	;

//comma expr for funcinvocation
Ce: Ce COMMA Expr				 		{if(flag == 't'){};}
	| COMMA Expr						{if(flag == 't'){};}
	;

Expr: Expr OR Expr 						{if(flag == 't'){};}
	| Expr AND Expr						{if(flag == 't'){};}
	| Expr LT Expr 						{if(flag == 't'){};}
	| Expr GT Expr 						{if(flag == 't'){};}
	| Expr EQ Expr 						{if(flag == 't'){};}
	| Expr NE Expr 						{if(flag == 't'){};}
	| Expr LE Expr 						{if(flag == 't'){};}
	| Expr GE Expr 						{if(flag == 't'){};}
	| Expr PLUS Expr 					{if(flag == 't'){};}
	| Expr MINUS Expr 					{if(flag == 't'){};}
	| Expr STAR Expr 					{if(flag == 't'){};}
	| Expr DIV Expr 					{if(flag == 't'){};}
	| Expr MOD Expr 					{if(flag == 't'){};}
	| NOT Expr 						{if(flag == 't'){};}
	| MINUS Expr 						{if(flag == 't'){};}
	| PLUS Expr 						{if(flag == 't'){};}
	| INTLIT 						{if(flag == 't'){};}
	| REALLIT						{if(flag == 't'){};}
	| ID							{if(flag == 't'){};}
	| FuncInvocation					{if(flag == 't'){};}
	| LPAR Expr RPAR					{if(flag == 't'){};}
	| LPAR error RPAR /*here or separate expression?*/	{print = 0; if(flag == 't'){$$ = NULL;};}
	;














%%
