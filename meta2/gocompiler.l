/*
Francisco Miranda	2015250590
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
id			(_)*{letra}(_|{letra}|{num})*|(_)+{num}(_|{letra}|{num})*
intlit			{num}|0(x|X)({num}|{hexa})+
reallit			{num}+"."{num}*{exp}?|{num}*{exp}|{num}*"."{num}+{exp}?
reserved		"++"|"--"|break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var

%{
	#include "y.tab.h"
	#include <string.h>
	char* addText(char* s1, char* s2, int length);
	int column = 1;
	int aux_column;
	int line = 1;
	int aux_line;
	char flag = '0';
	int print = 1;
	char ignore_strlit = 'n';
	int emit_semicolon = 0;
	char* st;
%}

%%
"//"						{BEGIN COMMENT; column+= yyleng;}
<COMMENT>"\n"|"\r"|"\r\n"			{BEGIN 0; line++; column=1; if (flag == 'l' && emit_semicolon == 1) printf("SEMICOLON\n"); if (flag != 'l' && emit_semicolon == 1){ emit_semicolon = 0; return SEMICOLON;} emit_semicolon = 0; }
<COMMENT>.					{column+=yyleng;}

"/*"						{BEGIN COMENTARIO;aux_column = column;aux_line = line; column+=yyleng;}
<COMENTARIO>"*/"				{BEGIN 0; column+=yyleng;}
<COMENTARIO>"\n"|"\r"|"\r\n"			{line++;column=1;}
<COMENTARIO>.					{column+=yyleng;}
<COMENTARIO><<EOF>>				{print = 0; emit_semicolon = 0; printf("Line %d, Column %d: unterminated comment\n",aux_line,aux_column); BEGIN 0;}

"\""						{BEGIN STR; st = addText(st, yytext, yyleng); aux_line = line; aux_column = column; column+=yyleng;}
<STR>\\r|\\n|\\t|\\f|\\\\|\\\"			{st = addText(st, yytext, yyleng); column+=yyleng;}
<STR>\\"\n"					{print = 0; printf("Line %d, column %d: invalid escape sequence (\\)\n",line,column); printf("Line %d, column %d: unterminated string literal\n",aux_line,aux_column); line++; column = 1; BEGIN 0; ignore_strlit = 'n';}
<STR>\\[^{num}]					{print = 0; printf("Line %d, column %d: invalid escape sequence (%s)\n",line,column, yytext); column+=yyleng; free(st); st = NULL; ignore_strlit = 'y';}
<STR>\n|"\r"|"\r\n"				{BEGIN 0; print = 0; emit_semicolon = 0; printf("Line %d, column %d: unterminated string literal\n",aux_line,aux_column); line++; column = 1; free(st); st = NULL; ignore_strlit = 'n';}
<STR>"\""					{BEGIN 0; st = addText(st, yytext, yyleng); if (ignore_strlit == 'n') emit_semicolon = 1; if (flag == 'l' && ignore_strlit == 'n'){if (st != NULL) printf("STRLIT(%s)\n", st);} column+=yyleng; if (flag != 'l' && ignore_strlit == 'n'){yylval.value = (char*)strdup(st); st = NULL; return STRLIT; } free(st); st = NULL; ignore_strlit = 'n';}
<STR><<EOF>>					{print = 0; emit_semicolon = 0; printf("Line %d, Column %d: unterminated string literal\n",aux_line,aux_column); BEGIN 0; free(st); st = NULL; ignore_strlit = 'n';}
<STR>.						{st = addText(st, yytext, yyleng); column+=yyleng;}

{whitespace}					{column++;}
\n|"\r\n"|"\r"				{if (flag == 'l' && emit_semicolon == 1) printf("SEMICOLON\n"); if (flag != 'l' && emit_semicolon == 1){emit_semicolon = 0; line++; column=1; return SEMICOLON;} 									line++; column=1; emit_semicolon = 0;}
;						{ emit_semicolon = 0; if (flag == 'l') printf("SEMICOLON\n"); column+=yyleng; if (flag != 'l') return SEMICOLON;}
_						{ emit_semicolon = 0; if (flag == 'l') printf("BLANKID\n");column+=yyleng; if (flag != 'l') return BLANKID;}
package						{ emit_semicolon = 0; if (flag == 'l') printf("PACKAGE\n");column+=yyleng; if (flag != 'l') return PACKAGE;}
return						{ emit_semicolon = 1; if (flag == 'l') printf("RETURN\n");column+=yyleng; if (flag != 'l') return RETURN;}
&&						{ emit_semicolon = 0; if (flag == 'l') printf("AND\n");column+=yyleng; if (flag != 'l') return AND;}
=						{ emit_semicolon = 0; if (flag == 'l') printf("ASSIGN\n");column+=yyleng; if (flag != 'l') return ASSIGN;}
"*"						{ emit_semicolon = 0; if (flag == 'l') printf("STAR\n");column+=yyleng; if (flag != 'l') return STAR;}
","						{ emit_semicolon = 0; if (flag == 'l') printf("COMMA\n");column+=yyleng; if (flag != 'l') return COMMA;}
"/"						{ emit_semicolon = 0; if (flag == 'l') printf("DIV\n");column+=yyleng; if (flag != 'l') return DIV;}
"=="						{ emit_semicolon = 0; if (flag == 'l') printf("EQ\n");column+=yyleng; if (flag != 'l') return EQ;}
">="						{ emit_semicolon = 0; if (flag == 'l') printf("GE\n");column+=yyleng; if (flag != 'l') return GE;}
">"						{ emit_semicolon = 0; if (flag == 'l') printf("GT\n");column+=yyleng; if (flag != 'l') return GT;}
"{"						{ emit_semicolon = 0; if (flag == 'l') printf("LBRACE\n");column+=yyleng; if (flag != 'l') return LBRACE;}
"<="						{ emit_semicolon = 0; if (flag == 'l') printf("LE\n");column+=yyleng; if (flag != 'l') return LE;}
"("						{ emit_semicolon = 0; if (flag == 'l') printf("LPAR\n");column+=yyleng; if (flag != 'l') return LPAR;}
"["						{ emit_semicolon = 0; if (flag == 'l') printf("LSQ\n");column+=yyleng; if (flag != 'l') return LSQ;}
"<"						{ emit_semicolon = 0; if (flag == 'l') printf("LT\n");column+=yyleng; if (flag != 'l') return LT;}
"-"						{ emit_semicolon = 0; if (flag == 'l') printf("MINUS\n");column+=yyleng; if (flag != 'l') return MINUS;}
"%"						{ emit_semicolon = 0; if (flag == 'l') printf("MOD\n");column+=yyleng; if (flag != 'l') return MOD;}
"!="						{ emit_semicolon = 0; if (flag == 'l') printf("NE\n");column+=yyleng; if (flag != 'l') return NE;}
"!"						{ emit_semicolon = 0; if (flag == 'l') printf("NOT\n");column+=yyleng; if (flag != 'l') return NOT;}
"||"						{ emit_semicolon = 0; if (flag == 'l') printf("OR\n");column+=yyleng; if (flag != 'l') return OR;}
"+"						{ emit_semicolon = 0; if (flag == 'l') printf("PLUS\n");column+=yyleng; if (flag != 'l') return PLUS;}
"}"						{ emit_semicolon = 1; if (flag == 'l') printf("RBRACE\n");column+=yyleng; if (flag != 'l') return RBRACE;}
")"						{ emit_semicolon = 1; if (flag == 'l') printf("RPAR\n");column+=yyleng; if (flag != 'l') return RPAR;}
"]"						{ emit_semicolon = 1; if (flag == 'l') printf("RSQ\n");column+=yyleng; if (flag != 'l') return RSQ;}
else						{ emit_semicolon = 0; if (flag == 'l') printf("ELSE\n");column+=yyleng; if (flag != 'l') return ELSE;}
for						{ emit_semicolon = 0; if (flag == 'l') printf("FOR\n");column+=yyleng; if (flag != 'l') return FOR;}
if						{ emit_semicolon = 0; if (flag == 'l') printf("IF\n");column+=yyleng; if (flag != 'l') return IF;}
var						{ emit_semicolon = 0; if (flag == 'l') printf("VAR\n");column+=yyleng; if (flag != 'l') return VAR;}
int						{ emit_semicolon = 0; if (flag == 'l') printf("INT\n");column+=yyleng; if (flag != 'l') return INT;}
float32						{ emit_semicolon = 0; if (flag == 'l') printf("FLOAT32\n");column+=yyleng; if (flag != 'l') return FLOAT32;}	
bool						{ emit_semicolon = 0; if (flag == 'l') printf("BOOL\n");column+=yyleng; if (flag != 'l') return BOOL;}
string						{ emit_semicolon = 0; if (flag == 'l') printf("STR\n");column+=yyleng; if (flag != 'l') return STR;}
fmt"."Println					{ emit_semicolon = 0; if (flag == 'l') printf("PRINT\n");column+=yyleng; if (flag != 'l') return PRINT;}
strconv"."Atoi					{ emit_semicolon = 0; if (flag == 'l') printf("PARSEINT\n");column+=yyleng; if (flag != 'l') return PARSEINT;}
func						{ emit_semicolon = 0; if (flag == 'l') printf("FUNC\n");column+=yyleng; if (flag != 'l') return FUNC;}
os\.Args					{ emit_semicolon = 0; if (flag == 'l') printf("CMDARGS\n");column+=yyleng; if (flag != 'l') return CMDARGS;}
{reserved}					{ emit_semicolon = 0; if (flag == 'l') printf("RESERVED(%s)\n", yytext);column+=yyleng; if (flag != 'l') return RESERVED;}
{id}						{ emit_semicolon = 1; if (flag == 'l') printf("ID(%s)\n", yytext);column+=yyleng; if (flag != 'l'){yylval.value = (char*)strdup(yytext); return ID;} }
{intlit}					{ emit_semicolon = 1; if (flag == 'l') printf("INTLIT(%s)\n", yytext);column+=yyleng; if (flag != 'l'){yylval.value = (char*)strdup(yytext); return 																									INTLIT;} }
{reallit}					{ emit_semicolon = 1; if (flag == 'l') printf("REALLIT(%s)\n", yytext);column+=yyleng; if (flag != 'l'){yylval.value = (char*)strdup(yytext); return 																									REALLIT;} }
<<EOF>>						{if (flag == 'l' && emit_semicolon == 1) printf("SEMICOLON\n"); if (flag != 'l' && emit_semicolon == 1) return SEMICOLON; return 0;}
.						{printf("Line %d, column %d: illegal character (%s)\n",line,column,yytext);column++; print = 0;}


%%
int main(int argc, char** argv)
{
    if(argc > 1 && argv[1][0] == '-') {
        flag = argv[1][1]; 
    }
    if (flag == 'l')	
    	yylex();
    else{
	yyparse();
	yylex_destroy();
    }
    return 0; 
}

void yyerror (char *s) {
    printf("Line %d, column %d: %s: %s\n", line, column - (int)strlen(yytext), s, yytext);
    print = 0;
}

int yywrap()
{
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
















