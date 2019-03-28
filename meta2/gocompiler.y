%{
    #include "structs.h"  
    node root;
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
%type <no> Block
%type <no> Else


%left COMMA 
%right ASSIGN
%left GE GT LE LT
%left OR
%left AND
%left EQ NE
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%left SINGLE
%nonassoc ELSE

%%

Program: PACKAGE ID SEMICOLON Declarations	{if(flag == 't'){root = criarNo("Program"); $$ = root; criarFilho(root, $4); free($2); if(print == 1) printTree(root, 0); } else freeTree(root); }
	| PACKAGE ID SEMICOLON			{if(flag == 't'){root = criarNo("Program"); $$ = root; free($2); if(print == 1) printTree(root, 0);} else freeTree(root);}
	;

Declarations: Declarations VarDeclaration SEMICOLON 	{if(flag == 't'){criarIrmao($1, $2); $$ = $1;};}
	| Declarations FuncDeclaration SEMICOLON	{if(flag == 't'){criarIrmao($1, $2); $$ = $1;};}
	| VarDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	| FuncDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	;

VarDeclaration: VAR VarSpec				{if(flag == 't'){$$ = $2;};} 
	| VAR LPAR VarSpec SEMICOLON RPAR		{if(flag == 't'){$$ = $3;};}
	;

VarSpec: ID Ci Type					{if(flag == 't'){$$ = criarNo("VarDecl"); criarFilho($$, criarNoTerminal("Id", $1)); criarIrmao($$, $2); typeIrmaos($$, $3);}; }
	| ID Type					{if(flag == 't'){$$ = criarNo("VarDecl"); criarFilho($$, $2); criarIrmao($$->filho, criarNoTerminal("Id", $1)); free($1);}; }
	;

//comma id for varspec
Ci: COMMA ID Ci  					{if(flag == 't'){$$ = criarNo("VarDecl"); criarFilho($$, criarNoTerminal("Id", $2)); free($2); criarIrmao($$, $3);};}			
	| COMMA ID					{if(flag == 't'){$$ = criarNo("VarDecl"); criarFilho($$, criarNoTerminal("Id", $2)); free($2);};}
	;

Type: INT						{if(flag == 't'){$$ = criarNo("Int");};}
	| FLOAT32					{if(flag == 't'){$$ = criarNo("Float32");};}
	| BOOL						{if(flag == 't'){$$ = criarNo("Bool");};}
	| STRING					{if(flag == 't'){$$ = criarNo("String");};}
	;


FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody 	{if(flag == 't'){$$ = criarNo("FuncDecl"); $$->filho = criarNo("FuncHeader"); criarFilho($$->filho, criarNoTerminal("Id", $2)); 											free($2); criarIrmao($$->filho->filho, $6); criarIrmao($$->filho->filho, $4); criarIrmao($$->filho, $7);}; }
	| FUNC ID LPAR Parameters RPAR FuncBody			{if(flag == 't'){$$ = criarNo("FuncDecl"); $$->filho = criarNo("FuncHeader"); criarFilho($$->filho, criarNoTerminal("Id", $2)); 											free($2);  criarIrmao($$->filho->filho, $4); criarIrmao($$->filho, $6);};}
	;

Parameters: /*empty*/						{if(flag == 't') $$ = criarNo("FuncParams");}
	| ID Type Cit						{if(flag == 't'){$$ = criarNo("FuncParams"); $$->filho = criarNo("ParamDecl"); $$->filho->filho = $2; 												criarIrmao($$->filho->filho, criarNoTerminal("Id", $1)); criarIrmao($$->filho, $3);}; }
	| ID Type						{if(flag == 't'){$$ = criarNo("FuncParams"); $$->filho = criarNo("ParamDecl"); $$->filho->filho = $2; 																criarIrmao($$->filho->filho, criarNoTerminal("Id", $1)); free($1);}; }
	;

//comma id type for parameters
Cit: Cit COMMA ID Type 						{if(flag == 't'){$$ = criarNo("ParamDecl"); $$->filho = $4; criarIrmao($$->filho, criarNoTerminal("Id", $3)); criarIrmao($$, $1); 																					free($3);};}
	| COMMA ID Type						{if(flag == 't'){$$ = criarNo("ParamDecl"); $$->filho = $3; criarIrmao($$->filho, criarNoTerminal("Id", $2)); free($2);};}
	;
		
FuncBody: LBRACE VarsAndStatements RBRACE			{if(flag == 't'){$$ = criarNo("FuncBody"); criarFilho($$,$2);};} //segfault
	| LBRACE RBRACE						{if(flag == 't'){$$ = criarNo("FuncBody");};}
	;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON 	{if(flag == 't'){criarIrmao($1,$2); $$ = $1;};}
	| VarsAndStatements Statement SEMICOLON			{if(flag == 't'){criarIrmao($1,verificaErro($2)); $$ = $1;};}
	| VarsAndStatements SEMICOLON				{if(flag == 't'){$$ = $1;};}
	| VarDeclaration SEMICOLON 				{if(flag == 't'){$$ = $1;};}
	| Statement SEMICOLON					{if(flag == 't'){$$ = verificaErro($1);};}
	| SEMICOLON						{if(flag == 't'){$$ = NULL;};}
	;

Statement: ID ASSIGN Expr 					{if(flag == 't'){$$ = criarNo("Assign"); criarFilho($$, criarNoTerminal("Id", $1)); free($1); criarIrmao($$->filho, verificaErro($3));};}
	| Block		 					{if(flag == 't'){$$ = $1; if ($$->filho == NULL) $$ = $$->irmao; else if($$->filho->irmao == NULL) $$ = $$->filho;};}
	| IF Expr Block Else					{if(flag == 't'){$$ = criarNo("If"); criarFilho($$, verificaErro($2)); criarIrmao($$->filho, $3); 																		if ($4 != NULL) criarIrmao($$->filho, $4);};} 
	| FOR Expr Block 					{if(flag == 't'){$$ = criarNo("For"); criarFilho($$, verificaErro($2)); criarIrmao($$->filho, $3);};}
	| FOR Block						{if(flag == 't'){$$ = criarNo("For"); criarFilho($$, $2);};}
	| RETURN Expr						{if(flag == 't'){$$ = criarNo("Return"); criarFilho($$, verificaErro($2));};}
	| RETURN						{if(flag == 't'){$$ = criarNo("Return");};}
	| FuncInvocation 					{if(flag == 't'){$$ = criarNo("Call"); criarFilho($$, verificaErro($1));};}
	| ParseArgs						{if(flag == 't'){$$ = criarNo("ParseArgs"); criarFilho($$, verificaErro($1));};}
	| PRINT LPAR Expr RPAR 					{if(flag == 't'){$$ = criarNo("Print"); criarFilho($$, verificaErro($3));};}
	| PRINT LPAR STRLIT RPAR				{if(flag == 't'){$$ = criarNo("Print"); criarFilho($$, criarNoTerminal("StrLit",$3)); free($3);};}
	| error							{print = 0; if(flag == 't'){$$ = NULL;};}
	;

Block: LBRACE Ss RBRACE						{if(flag == 't'){$$ = criarNo("Block"); criarFilho($$, $2);};}
	| LBRACE RBRACE						{if(flag == 't'){$$ = criarNo("Block");};}
	;

Else: ELSE Block						{if(flag == 't'){$$ = $2;};}
	| 							{if(flag == 't') $$ = criarNo("Block");}
	;


//statement semicolon for Statements
Ss: Ss Statement SEMICOLON 					{if(flag == 't'){criarIrmao($1, verificaErro($2)); $$ = $1;};}
	| Statement SEMICOLON					{if(flag == 't'){$$ = verificaErro($1);};}
	;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR 	{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1); criarIrmao($$, verificaErro($9));};}
	| ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR			{print = 0; if(flag == 't'){$$ = NULL;};}
	;

FuncInvocation: ID LPAR RPAR					{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1);};}
	| ID LPAR Expr RPAR					{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1); criarIrmao($$, verificaErro($3));};}
	| ID LPAR Expr Ce RPAR					{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1); criarIrmao($$, verificaErro($3)); criarIrmao($$, $4);};}
	| ID LPAR error RPAR					{print = 0; if(flag == 't'){$$ = NULL;};}
	;

//comma expr for funcinvocation
Ce: Ce COMMA Expr				 		{if(flag == 't'){criarIrmao($1, verificaErro($3)); $$ = $1;};}
	| COMMA Expr						{if(flag == 't'){$$ = verificaErro($2);};}
	;

Expr: Expr OR Expr 						{if(flag == 't'){$$ = criarNo("Or"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr AND Expr						{if(flag == 't'){$$ = criarNo("And"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr LT Expr 						{if(flag == 't'){$$ = criarNo("Lt"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr GT Expr 						{if(flag == 't'){$$ = criarNo("Gt"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr EQ Expr 						{if(flag == 't'){$$ = criarNo("Eq"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}	
	| Expr NE Expr 						{if(flag == 't'){$$ = criarNo("Ne"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr LE Expr 						{if(flag == 't'){$$ = criarNo("Le"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr GE Expr 						{if(flag == 't'){$$ = criarNo("Ge"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr PLUS Expr 					{if(flag == 't'){$$ = criarNo("Add"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr MINUS Expr 					{if(flag == 't'){$$ = criarNo("Sub"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr STAR Expr 					{if(flag == 't'){$$ = criarNo("Mul"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr DIV Expr 					{if(flag == 't'){$$ = criarNo("Div"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| Expr MOD Expr 					{if(flag == 't'){$$ = criarNo("Mod"); criarFilho($$, $1); criarIrmao($$->filho, verificaErro($3));};}
	| NOT Expr 	%prec SINGLE				{if(flag == 't'){$$ = criarNo("Not"); criarFilho($$, verificaErro($2));};}
	| MINUS Expr 	%prec SINGLE				{if(flag == 't'){$$ = criarNo("Minus"); criarFilho($$, verificaErro($2));};}
	| PLUS Expr 	%prec SINGLE				{if(flag == 't'){$$ = criarNo("Plus"); criarFilho($$, verificaErro($2));};}
	| INTLIT 						{if(flag == 't'){$$ = criarNoTerminal("IntLit", $1); free($1);};}
	| REALLIT						{if(flag == 't'){$$ = criarNoTerminal("RealLit", $1); free($1);};}
	| ID							{if(flag == 't'){$$ = criarNoTerminal("Id", $1); free($1);};}
	| FuncInvocation					{if(flag == 't'){$$ = criarNo("Call"); criarFilho($$, $1);};}
	| LPAR Expr RPAR					{if(flag == 't'){$$ = verificaErro($2);};}
	| LPAR error RPAR 					{print = 0; if(flag == 't'){$$ = NULL;};}
	;














%%

