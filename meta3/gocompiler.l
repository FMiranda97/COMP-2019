/*
Francisco Miranda	2015250592
Jonas Rua		2016218077
*/
%X COMENTARIO
%X STR
%X COMMENT

num			[0-9]+
hexa			[a-fA-F]+
letra			[a-zA-Z]+
exp			(e|E)("+"|"-")?{num}+
whitespace		" "|"\t"
strlit			(.^["\n""\"""\r""\\"])*
id			(_)*{letra}(_|{letra}|{num})*
intlit			{num}|0(x|X)({num}|{hexa})+
reallit			{num}+"."{num}*{exp}?|{num}*{exp}|{num}*"."{num}+{exp}?
reserved		"++"|"--"|break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var
escape			"\\r"|"\n"|"\\t"|"\\f"|\\\\|\\\"

%{
	#include "y.tab.h"
	#include "structs.h" 
	char* addText(char* s1, char* s2, int length);
	int column = 1;
	int aux_column;
	int line = 1;
	int aux_line;
	char flag = '0';
	char ignore_strlit = 'n';
	int emit_semicolon = 0;
	char* st;
	char flagPrintTable = 'n';
	gTable symTab;
	table auxSymTab = NULL;
	char flagError = 'n';
	char printAST = 'y';
%}

%%
"//"						{BEGIN COMMENT; column+= yyleng;}
<COMMENT>"\n"|"\r"|"\r\n"			{BEGIN 0; line++; column=1; if (flag == 'l' && emit_semicolon == 1) printf("SEMICOLON\n"); if (flag == 't' && emit_semicolon == 1) return SEMICOLON; 																	emit_semicolon = 0; }
<COMMENT>.					{column+=yyleng;}

"/*"						{BEGIN COMENTARIO;aux_column = column;aux_line = line; column+=yyleng;}
<COMENTARIO>"*/"				{BEGIN 0; column+=yyleng;}
<COMENTARIO>"\n"|"\r"|"\r\n"			{line++;column=1;}
<COMENTARIO>.					{column+=yyleng;}
<COMENTARIO><<EOF>>				{printf("Line %d, Column %d: unterminated comment\n",aux_line,aux_column); BEGIN 0; emit_semicolon = 0;}

"\""						{BEGIN STRING; st = addText(st, yytext, yyleng); aux_line = line; aux_column = column; column+=yyleng;}
<STR>\\r|\\n|\\t|\\f|\\\\|\\\"			{st = addText(st, yytext, yyleng); column+=yyleng;}
<STR>\\"\n"					{printf("Line %d, column %d: invalid escape sequence (\\)\n",line,column); printf("Line %d, column %d: unterminated string literal\n",aux_line,aux_column); 																line++; column = 1; BEGIN 0; ignore_strlit = 'n'; emit_semicolon = 0;}
<STR>\\[^{num}]					{printf("Line %d, column %d: invalid escape sequence (%s)\n",line,column, yytext); column+=yyleng; free(st); st = NULL; ignore_strlit = 'y'; emit_semicolon = 0;}
<STR>"\n"|"\r"|"\r\n"				{BEGIN 0; printf("Line %d, column %d: unterminated string literal\n",aux_line,aux_column); line++; column = 1; free(st); st = NULL; ignore_strlit = 'n'; emit_semicolon = 0;}
<STR>"\""					{BEGIN 0; st = addText(st, yytext, yyleng); if (ignore_strlit == 'n') emit_semicolon = 1; if (flag == 'l' && ignore_strlit == 'n'){if (st != NULL) printf("STRLIT(%s)\n", st);} column+=yyleng; if (flag == 't' && ignore_strlit == 'n'){yylval.info = sendInfo(yytext); st = NULL; return STRLIT; } free(st); st = NULL; ignore_strlit = 'n';}
<STR><<EOF>>					{printf("Line %d, Column %d: unterminated string literal\n",aux_line,aux_column); BEGIN 0; free(st); st = NULL; ignore_strlit = 'n'; emit_semicolon = 0;}
<STR>.						{st = addText(st, yytext, yyleng); column+=yyleng;}

{whitespace}					{column++;}
"\n"|"\r\n"|"\r"				{if (flag == 'l' && emit_semicolon == 1) printf("SEMICOLON\n"); if (flag == 't' && emit_semicolon == 1){emit_semicolon = 0; return SEMICOLON;} 									line++; column=1; emit_semicolon = 0;}
;						{ emit_semicolon = 0; if (flag == 'l') printf("SEMICOLON\n"); column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return SEMICOLON;}}
_						{ emit_semicolon = 0; if (flag == 'l') printf("BLANKID\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return BLANKID;}}
package						{ emit_semicolon = 0; if (flag == 'l') printf("PACKAGE\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return PACKAGE;}}
return						{ emit_semicolon = 1; if (flag == 'l') printf("RETURN\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return RETURN;}}
&&						{ emit_semicolon = 0; if (flag == 'l') printf("AND\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return AND;}}
=						{ emit_semicolon = 0; if (flag == 'l') printf("ASSIGN\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return ASSIGN;}}
"*"						{ emit_semicolon = 0; if (flag == 'l') printf("STAR\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return STAR;}}
","						{ emit_semicolon = 0; if (flag == 'l') printf("COMMA\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return COMMA;}}
"/"						{ emit_semicolon = 0; if (flag == 'l') printf("DIV\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return DIV;}}
"=="						{ emit_semicolon = 0; if (flag == 'l') printf("EQ\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return EQ;}}
">="						{ emit_semicolon = 0; if (flag == 'l') printf("GE\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return GE;}}
">"						{ emit_semicolon = 0; if (flag == 'l') printf("GT\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return GT;}}
"{"						{ emit_semicolon = 0; if (flag == 'l') printf("LBRACE\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return LBRACE;}}
"<="						{ emit_semicolon = 0; if (flag == 'l') printf("LE\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return LE;}}
"("						{ emit_semicolon = 0; if (flag == 'l') printf("LPAR\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return LPAR;}}
"["						{ emit_semicolon = 0; if (flag == 'l') printf("LSQ\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return LSQ;}}
"<"						{ emit_semicolon = 0; if (flag == 'l') printf("LT\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return LT;}}
"-"						{ emit_semicolon = 0; if (flag == 'l') printf("MINUS\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return MINUS;}}
"%"						{ emit_semicolon = 0; if (flag == 'l') printf("MOD\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return MOD;}}
"!="						{ emit_semicolon = 0; if (flag == 'l') printf("NE\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return NE;}}
"!"						{ emit_semicolon = 0; if (flag == 'l') printf("NOT\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return NOT;}}
"||"						{ emit_semicolon = 0; if (flag == 'l') printf("OR\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return OR;}}
"+"						{ emit_semicolon = 0; if (flag == 'l') printf("PLUS\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return PLUS;}}
"}"						{ emit_semicolon = 1; if (flag == 'l') printf("RBRACE\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return RBRACE;}}
")"						{ emit_semicolon = 1; if (flag == 'l') printf("RPAR\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return RPAR;}}
"]"						{ emit_semicolon = 1; if (flag == 'l') printf("RSQ\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return RSQ;}}
else						{ emit_semicolon = 0; if (flag == 'l') printf("ELSE\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return ELSE;}}
for						{ emit_semicolon = 0; if (flag == 'l') printf("FOR\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return FOR;}}
if						{ emit_semicolon = 0; if (flag == 'l') printf("IF\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return IF;}}
var						{ emit_semicolon = 0; if (flag == 'l') printf("VAR\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return VAR;}}
int						{ emit_semicolon = 0; if (flag == 'l') printf("INT\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return INT;}}
float32						{ emit_semicolon = 0; if (flag == 'l') printf("FLOAT32\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return FLOAT32;}}	
bool						{ emit_semicolon = 0; if (flag == 'l') printf("BOOL\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return BOOL;}}
string						{ emit_semicolon = 0; if (flag == 'l') printf("STRING\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return STRING;}}
fmt"."Println					{ emit_semicolon = 0; if (flag == 'l') printf("PRINT\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return PRINT;}}
strconv"."Atoi					{ emit_semicolon = 0; if (flag == 'l') printf("PARSEINT\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return PARSEINT;}}
func						{ emit_semicolon = 0; if (flag == 'l') printf("FUNC\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return FUNC;}}
os\.Args					{ emit_semicolon = 0; if (flag == 'l') printf("CMDARGS\n");column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return CMDARGS;}}
{reserved}					{ emit_semicolon = 0; if (flag == 'l') printf("RESERVED(%s)\n", yytext);column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return RESERVED;}}
{id}						{ emit_semicolon = 1; if (flag == 'l') printf("ID(%s)\n", yytext);column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return ID;} }
{intlit}					{ emit_semicolon = 1; if (flag == 'l') printf("INTLIT(%s)\n", yytext);column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return 																									INTLIT;} }
{reallit}					{ emit_semicolon = 1; if (flag == 'l') printf("REALLIT(%s)\n", yytext);column+=yyleng; if (flag == 't'){yylval.info = sendInfo(yytext); return 																									REALLIT;} }
<<EOF>>						{if (flag == 'l' && emit_semicolon == 1) printf("SEMICOLON\n"); if (flag == 't' && emit_semicolon == 1) return SEMICOLON; return 0;}
.						{printf("Line %d, column %d: illegal character (%s)\n",line,column,yytext); column++; emit_semicolon = 0;}


%%
int main(int argc, char** argv)
{
    if(argc > 1 && argv[1][0] == '-') {
        flag = argv[1][1]; 
    }
    if (flag == 'l')	
    	yylex();
    else if (flag == 't'){
	yyparse();
	yylex_destroy();
	freeTree(root);
    } else if (flag == 's'){
	flag = 't';
	flagPrintTable = 'y';
	yyparse();
	if(flagError == 'n') {
		symTab = startTable();
		auxSymTab = createSymbolTable("", "");
		checkSemantics(root->filho, symTab, auxSymTab);
		if(flagPrintTable == 'y') {
		    printGTable(symTab);
		    printTable(auxSymTab);
		    printAnnotedTree(root, 0);
		}
    	}else freeTree(root);
	yylex_destroy();
    }else{
	flag = 't';
	flagPrintTable = 'y';
	yyparse();
	if(flagError == 'n') {
		symTab = startTable();
		auxSymTab = createSymbolTable("", "");
		checkSemantics(root->filho, symTab, auxSymTab);
    	}else freeTree(root);
	yylex_destroy();
    }
    return 0; 
}

tokenInfo sendInfo(char *text){
	tokenInfo aux = (tokenInfo) malloc(sizeof(info_node));
	aux->nome = strdup(text);
	aux->line = line;
	aux->column = column - yyleng;
	return aux;
}

void yyerror (char *s) {
	flagError = 'y';
	printf("Line %d, column %d: %s: %s\n", line, column - (int)strlen(yytext), s, yytext);
}

int yywrap(){
	return 1;
}

char* addText(char* s1, char* s2, int length){
	char *aux;
	if (s1 != NULL){
		aux = (char *) malloc((strlen(s1) + length + 1) * sizeof(char));
		strcpy(aux, s1);
		strcat(aux, s2);
	}else {
		aux = (char *) malloc((length + 1) * sizeof(char));
		strcpy(aux, s2);
	}
	return aux;
}















