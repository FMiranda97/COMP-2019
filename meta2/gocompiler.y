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

Program: PACKAGE ID SEMICOLON Declarations	{if(flag == 't'){ root = createNode("Program"); addChild(root, $4); $$ = root; if(print == 1) printTree(root, 0); else freeTree(root);}; }
	| PACKAGE ID SEMICOLON			{if(flag == 't'){$$ = createNodeTerminal("Id", $2); free($2);};}
	;

Declarations: Declarations VarDeclaration SEMICOLON 	{if(flag == 't'){addSibling($1, $2); $$ = $1;};}
	| Declarations FuncDeclaration SEMICOLON	{if(flag == 't'){addSibling($1, $2); $$ = $1;};}
	| VarDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	| FuncDeclaration SEMICOLON 			{if(flag == 't'){$$ = $1;};}
	;

VarDeclaration: VAR VarSpec				{if(flag == 't'){$$ = $2;};} 
	| VAR LPAR VarSpec SEMICOLON RPAR		{if(flag == 't'){$$ = $3;};}
	;

VarSpec: ID Ci Type					{if(flag == 't'){$$ = createNode("VarDecl"); addChild($$, createNodeTerminal("Id", $1)); addSibling($$, $2); typeSpecDef($$, $3);}; }
	| ID Type					{if(flag == 't'){$$ = createNode("VarDecl"); addChild($$, $2); addSibling($$->child, createNodeTerminal("Id", $1));}; }
	;

//comma id for varspec
Ci: COMMA ID Ci  					{if(flag == 't'){$$ = createNode("VarDecl"); addChild($$, createNodeTerminal("Id", $2)); addSibling($$, $3);};}			
	| COMMA ID					{if(flag == 't'){$$ = createNode("VarDecl"); addChild($$, createNodeTerminal("Id", $2));};}
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
		
FuncBody: LBRACE VarsAndStatements RBRACE			{if(flag == 't'){$$ = createNode("FuncBody"); addChild($$,$2);};} //segfault
	| LBRACE RBRACE						{if(flag == 't'){$$ = createNode("FuncBody");};}
	;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON 	{if(flag == 't'){addSibling($1,$2); $$ = $1;};}
	| VarsAndStatements Statement SEMICOLON			{if(flag == 't'){addSibling($1,$2); $$ = $1;};}
	| VarsAndStatements SEMICOLON				{if(flag == 't'){$$ = $1;};}
	| VarDeclaration SEMICOLON 				{if(flag == 't'){$$ = $1;};}
	| Statement SEMICOLON					{if(flag == 't'){$$ = $1;};}
	| SEMICOLON						{if(flag == 't'){$$ = NULL;};}
	;

Statement: ID ASSIGN Expr 					{if(flag == 't'){$$ = createNode("Assign"); addChild($$, createNodeTerminal("Id", $1)); addSibling($$->child, $3);};}
	| Block		 					{if(flag == 't'){$$ = $1;};}
	| IF Expr Block Else					{if(flag == 't'){$$ = createNode("If"); addChild($$, $2); addSibling($$->child, $3); addSibling($$->child, $4);};} 
	| FOR Expr Block 					{if(flag == 't'){$$ = createNode("For"); addChild($$, $2); addSibling($$->child, $3);};}
	| FOR Block						{if(flag == 't'){$$ = createNode("For"); addChild($$, $2);};}
	| RETURN Expr						{if(flag == 't'){$$ = createNode("Return"); addChild($$, $2);};}
	| RETURN						{if(flag == 't'){$$ = createNode("Return");};}
	| FuncInvocation 					{if(flag == 't'){$$ = createNode("Call"); addChild($$, $1);};}
	| ParseArgs						{if(flag == 't'){$$ = createNode("ParseArgs"); addChild($$, $1);};}
	| PRINT LPAR Expr RPAR 					{if(flag == 't'){$$ = createNode("Print"); addChild($$, $3);};}
	| PRINT LPAR STRLIT RPAR				{if(flag == 't'){$$ = createNode("Print"); addChild($$, createNodeTerminal("Strlit",$3));};}
	| error							{print = 0; if(flag == 't'){$$ = NULL;};}
	;

Block: LBRACE Ss RBRACE						{if(flag == 't'){$$ = createNode("Block"); addChild($$, $2);};}
	| LBRACE RBRACE						{if(flag == 't'){$$ = createNode("Block");};}
	;

Else: ELSE Block						{if(flag == 't'){$$ = $2;};}
	| 							{if(flag == 't') $$ = NULL;}
	;


//statement semicolon for Statements
Ss: Ss Statement SEMICOLON 					{if(flag == 't'){addSibling($1, $2); $$ = $1;};}
	| Statement SEMICOLON					{if(flag == 't'){$$ = $1;};}
	;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR 	{if(flag == 't'){$$ = createNodeTerminal("Id", $1); addSibling($$, $9);};}
	| ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR			{print = 0; if(flag == 't'){$$ = NULL;};}
	;

FuncInvocation: ID LPAR RPAR					{if(flag == 't'){$$ = createNodeTerminal("Id", $1); };}
	| ID LPAR Expr RPAR					{if(flag == 't'){$$ = createNodeTerminal("Id", $1); addSibling($$, $3);};}
	| ID LPAR Expr Ce RPAR					{if(flag == 't'){$$ = createNodeTerminal("Id", $1); addSibling($$, $3); addSibling($$, $4);};}
	| ID LPAR error RPAR					{print = 0; if(flag == 't'){$$ = NULL;};}
	;

//comma expr for funcinvocation
Ce: Ce COMMA Expr				 		{if(flag == 't'){addSibling($1, $3); $$ = $1;};}
	| COMMA Expr						{if(flag == 't'){$$ = $2;};}
	;

Expr: Expr OR Expr 						{if(flag == 't'){$$ = createNode("Or"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr AND Expr						{if(flag == 't'){$$ = createNode("And"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr LT Expr 						{if(flag == 't'){$$ = createNode("Lt"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr GT Expr 						{if(flag == 't'){$$ = createNode("Gt"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr EQ Expr 						{if(flag == 't'){$$ = createNode("Eq"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr NE Expr 						{if(flag == 't'){$$ = createNode("Ne"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr LE Expr 						{if(flag == 't'){$$ = createNode("Le"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr GE Expr 						{if(flag == 't'){$$ = createNode("Ge"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr PLUS Expr 					{if(flag == 't'){$$ = createNode("Add"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr MINUS Expr 					{if(flag == 't'){$$ = createNode("Sub"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr STAR Expr 					{if(flag == 't'){$$ = createNode("Mul"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr DIV Expr 					{if(flag == 't'){$$ = createNode("Div"); addChild($$, $1); addSibling($$->child, $3);};}
	| Expr MOD Expr 					{if(flag == 't'){$$ = createNode("Mod"); addChild($$, $1); addSibling($$->child, $3);};}
	| NOT Expr 						{if(flag == 't'){$$ = createNode("Not"); addChild($$, $2);};}
	| MINUS Expr 						{if(flag == 't'){$$ = createNode("Minus"); addChild($$, $2);};}
	| PLUS Expr 						{if(flag == 't'){$$ = createNode("Plus"); addChild($$, $2);};}
	| INTLIT 						{if(flag == 't'){$$ = createNodeTerminal("Intlit", $1);};}
	| REALLIT						{if(flag == 't'){$$ = createNodeTerminal("Reallit", $1);};}
	| ID							{if(flag == 't'){$$ = createNodeTerminal("Id", $1);};}
	| FuncInvocation					{if(flag == 't'){$$ = createNode("Call"); addChild($$, $1);};}
	| LPAR Expr RPAR					{if(flag == 't'){$$ = $2;};}
	| LPAR error RPAR 					{print = 0; if(flag == 't'){$$ = NULL;};}
	;














%%

