%{
    #include "structs.h"  
    node root;
%}

%token <info> SEMICOLON
%token <info> BLANKID
%token <info> PACKAGE
%token <info> RETURN
%token <info> AND
%token <info> ASSIGN
%token <info> STAR
%token <info> COMMA
%token <info> DIV
%token <info> EQ
%token <info> GE
%token <info> GT
%token <info> LBRACE
%token <info> LE
%token <info> LPAR
%token <info> LSQ
%token <info> LT
%token <info> MINUS
%token <info> MOD
%token <info> NE
%token <info> NOT
%token <info> OR
%token <info> PLUS
%token <info> RBRACE
%token <info> RPAR
%token <info> RSQ
%token <info> ELSE
%token <info> FOR
%token <info> IF
%token <info> VAR
%token <info> INT
%token <info> FLOAT32
%token <info> BOOL
%token <info> STRING
%token <info> PRINT
%token <info> PARSEINT
%token <info> FUNC
%token <info> CMDARGS
%token <info> ID
%token <info> INTLIT
%token <info> REALLIT
%token <info> STRLIT
%token <info> RESERVED


%union {
    struct _info_node *info;
    struct _tree_node *no;
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
%type <no> Block
%type <no> Else


%left COMMA 
%right ASSIGN
%left OR
%left AND
%left EQ NE
%left GE GT LE LT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT

%%

Program: PACKAGE ID SEMICOLON Declarations	{if(flag == 't'){ root = criarNo("Program", NULL); criarFilho(root, $4); $$ = root; if(printAST == 'y' && flagPrintTable == 'n') printTree(root, 0); else if (flagPrintTable == 'n') freeTree(root);}; }
	| PACKAGE ID SEMICOLON			{if(flag == 't'){$$ = criarNoTerminal("Id", $2); free($2);};}
	;

Declarations: Declarations VarDeclaration SEMICOLON 	{if(flag == 't'){criarIrmao($1, $2); $$ = $1;};}
	| Declarations FuncDeclaration SEMICOLON	{if(flag == 't'){criarIrmao($1, $2); $$ = $1;};}
	| VarDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	| FuncDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	;

VarDeclaration: VAR VarSpec				{if(flag == 't'){$$ = $2;};} 
	| VAR LPAR VarSpec SEMICOLON RPAR		{if(flag == 't'){$$ = $3;};}
	;

VarSpec: ID Ci Type					{if(flag == 't'){$$ = criarNo("VarDecl", NULL); criarFilho($$, criarNoTerminal("Id", $1)); criarIrmao($$, $2); typeIrmaos($$, $3);}; }
	| ID Type					{if(flag == 't'){$$ = criarNo("VarDecl", NULL); criarFilho($$, $2); criarIrmao($$->filho, criarNoTerminal("Id", $1)); free($1);}; }
	;

//comma id for varspec
Ci: COMMA ID Ci  					{if(flag == 't'){$$ = criarNo("VarDecl", NULL); criarFilho($$, criarNoTerminal("Id", $2)); free($2); criarIrmao($$, $3);};}			
	| COMMA ID					{if(flag == 't'){$$ = criarNo("VarDecl", NULL); criarFilho($$, criarNoTerminal("Id", $2)); free($2);};}
	;

Type: INT						{if(flag == 't'){$$ = criarNo("Int", NULL);};}
	| FLOAT32					{if(flag == 't'){$$ = criarNo("Float32", NULL);};}
	| BOOL						{if(flag == 't'){$$ = criarNo("Bool", NULL);};}
	| STRING					{if(flag == 't'){$$ = criarNo("String", NULL);};}
	;


FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody 	{if(flag == 't'){$$ = criarNo("FuncDecl", NULL); $$->filho = criarNo("FuncHeader", NULL); criarFilho($$->filho, criarNoTerminal("Id", $2)); 											free($2); criarIrmao($$->filho->filho, $6); criarIrmao($$->filho->filho, $4); criarIrmao($$->filho, $7);}; }
	| FUNC ID LPAR Parameters RPAR FuncBody			{if(flag == 't'){$$ = criarNo("FuncDecl", NULL); $$->filho = criarNo("FuncHeader", NULL); criarFilho($$->filho, criarNoTerminal("Id", $2)); 											free($2);  criarIrmao($$->filho->filho, $4); criarIrmao($$->filho, $6);};}
	;

Parameters: /*empty*/						{if(flag == 't') $$ = criarNo("FuncParams", NULL);}
	| ID Type Cit						{if(flag == 't'){$$ = criarNo("FuncParams", NULL); $$->filho = criarNo("ParamDecl", NULL); $$->filho->filho = $2; 												criarIrmao($$->filho->filho, criarNoTerminal("Id", $1)); criarIrmao($$->filho, $3);}; }
	| ID Type						{if(flag == 't'){$$ = criarNo("FuncParams", NULL); $$->filho = criarNo("ParamDecl", NULL); $$->filho->filho = $2; 																criarIrmao($$->filho->filho, criarNoTerminal("Id", $1)); free($1);}; }
	;

//comma id type for parameters
Cit: COMMA ID Type Cit				{if(flag == 't'){$$ = criarNo("ParamDecl", NULL); $$->filho = $3; criarIrmao($$->filho, criarNoTerminal("Id", $2)); criarIrmao($$, $4); free($2);};}
	| COMMA ID Type						{if(flag == 't'){$$ = criarNo("ParamDecl", NULL); $$->filho = $3; criarIrmao($$->filho, criarNoTerminal("Id", $2)); free($2);};}
	;
		
FuncBody: LBRACE VarsAndStatements RBRACE			{if(flag == 't'){$$ = criarNo("FuncBody", NULL); criarFilho($$,$2);};} //segfault
	| LBRACE RBRACE						{if(flag == 't'){$$ = criarNo("FuncBody", NULL);};}
	;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON 	{if(flag == 't'){criarIrmao($1,$2); $$ = $1;};}
	| VarsAndStatements Statement SEMICOLON			{if(flag == 't'){criarIrmao($1,$2); $$ = $1;};}
	| VarsAndStatements SEMICOLON				{if(flag == 't'){$$ = $1;};}
	| VarDeclaration SEMICOLON 				{if(flag == 't'){$$ = $1;};}
	| Statement SEMICOLON					{if(flag == 't'){$$ = $1;};}
	| SEMICOLON						{if(flag == 't'){$$ = NULL;};}
	;

Statement: ID ASSIGN Expr 					{if(flag == 't'){$$ = criarNo("Assign", NULL); criarFilho($$, criarNoTerminal("Id", $1)); free($1); criarIrmao($$->filho, $3);};}
	| Block		 					{if(flag == 't'){$$ = $1;};}
	| IF Expr Block Else					{if(flag == 't'){$$ = criarNo("If", NULL); criarFilho($$, $2); criarIrmao($$->filho, $3); criarIrmao($$->filho, $4);};} 
	| FOR Expr Block 					{if(flag == 't'){$$ = criarNo("For", NULL); criarFilho($$, $2); criarIrmao($$->filho, $3);};}
	| FOR Block						{if(flag == 't'){$$ = criarNo("For", NULL); criarFilho($$, $2);};}
	| RETURN Expr						{if(flag == 't'){$$ = criarNo("Return", NULL); criarFilho($$, $2);};}
	| RETURN						{if(flag == 't'){$$ = criarNo("Return", NULL);};}
	| FuncInvocation 					{if(flag == 't'){$$ = criarNo("Call", NULL); criarFilho($$, $1);};}
	| ParseArgs						{if(flag == 't'){$$ = criarNo("ParseArgs", NULL); criarFilho($$, $1);};}
	| PRINT LPAR Expr RPAR 					{if(flag == 't'){$$ = criarNo("Print", NULL); criarFilho($$, $3);};}
	| PRINT LPAR STRLIT RPAR				{if(flag == 't'){$$ = criarNo("Print", NULL); criarFilho($$, criarNoTerminal("StrLit",$3)); free($3);};}
	| error							{printAST = 'n'; if(flag == 't'){$$ = NULL;};}
	;

Block: LBRACE Ss RBRACE						{if(flag == 't'){$$ = criarNo("Block", NULL); criarFilho($$, $2);};}
	| LBRACE RBRACE						{if(flag == 't'){$$ = criarNo("Block", NULL);};}
	;

Else: ELSE Block						{if(flag == 't'){$$ = $2;};}
	| 							{if(flag == 't'){$$ = criarNo("Block", NULL);};}
	;


//statement semicolon for Statements
Ss: Ss Statement SEMICOLON 					{if(flag == 't'){criarIrmao($1, $2); $$ = $1;};}
	| Statement SEMICOLON					{if(flag == 't'){$$ = $1;};}
	;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR 	{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1); criarIrmao($$, $9);};}
	| ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR			{printAST = 'n'; if(flag == 't'){$$ = NULL;};}
	;

FuncInvocation: ID LPAR RPAR					{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1);};}
	| ID LPAR Expr RPAR					{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1); criarIrmao($$, $3);};}
	| ID LPAR Expr Ce RPAR					{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1); criarIrmao($$, $3); criarIrmao($$, $4);};}
	| ID LPAR error RPAR					{printAST = 'n'; if(flag == 't'){$$ = NULL;};}
	;

//comma expr for funcinvocation
Ce: Ce COMMA Expr				 		{if(flag == 't'){criarIrmao($1, $3); $$ = $1;};}
	| COMMA Expr						{if(flag == 't'){$$ = $2;};}
	;

Expr: Expr OR Expr 						{if(flag == 't'){$$ = criarNo("Or", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr AND Expr						{if(flag == 't'){$$ = criarNo("And", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr LT Expr 						{if(flag == 't'){$$ = criarNo("Lt", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr GT Expr 						{if(flag == 't'){$$ = criarNo("Gt", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr EQ Expr 						{if(flag == 't'){$$ = criarNo("Eq", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}	
	| Expr NE Expr 						{if(flag == 't'){$$ = criarNo("Ne", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr LE Expr 						{if(flag == 't'){$$ = criarNo("Le", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr GE Expr 						{if(flag == 't'){$$ = criarNo("Ge", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr PLUS Expr 					{if(flag == 't'){$$ = criarNo("Add", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr MINUS Expr 					{if(flag == 't'){$$ = criarNo("Sub", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr STAR Expr 					{if(flag == 't'){$$ = criarNo("Mul", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr DIV Expr 					{if(flag == 't'){$$ = criarNo("Div", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| Expr MOD Expr 					{if(flag == 't'){$$ = criarNo("Mod", NULL); criarFilho($$, $1); criarIrmao($$->filho, $3);};}
	| NOT Expr 						{if(flag == 't'){$$ = criarNo("Not", NULL); criarFilho($$, $2);};}
	| MINUS Expr 						{if(flag == 't'){$$ = criarNo("Minus", NULL); criarFilho($$, $2);};}
	| PLUS Expr 						{if(flag == 't'){$$ = criarNo("Plus", NULL); criarFilho($$, $2);};}
	| INTLIT 						{if(flag == 't'){$$ = criarNoTerminal("IntLit", $1); free($1);};}
	| REALLIT						{if(flag == 't'){$$ = criarNoTerminal("RealLit", $1); free($1);};}
	| ID							{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1);};}
	| FuncInvocation					{if(flag == 't'){$$ = criarNo("Call", NULL); criarFilho($$, $1);};}
	| LPAR Expr RPAR					{if(flag == 't'){$$ = $2;};}
	| LPAR error RPAR 					{printAST = 'n'; if(flag == 't'){$$ = NULL;};}
	;














%%

