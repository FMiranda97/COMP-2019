/*
Francisco Miranda	2015250590
Jonas Rua		2016218077
*/
%X COMENTARIO
%X STRING
%X COMMENT

num			[0-9]+
hexa			[a-fA-f]+
letra			[a-zA-Z]+
exp			(e|E)("+"|"-")?{num}+
whitespace		" "|"\t"
strlit			(.^["\n""\"""\r""\\"])*
id			(_|{letra})(_|{letra}|{num})*
intlit			{num}|0(x|X)({num}|{hexa})*
reallit			{num}+"."{num}*{exp}?|{num}*{exp}|{num}*"."{num}+{exp}?
reserved		"++"|"--"|break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var

%{
int column = 1;
int aux_column;
int line = 1;
int aux_line;
char flag = 'a';
int emit_semicolon = 0;
%}

%%
"//"						{BEGIN COMMENT; column+= yyleng;}
<COMMENT>"\n"|"\r"|"\r\n"			{BEGIN 0; line++; column=1;}
<COMMENT>.					{column+=yyleng;}

"/*"						{BEGIN COMENTARIO;aux_column = column;aux_line = line;}
<COMENTARIO>"*/"				{BEGIN 0; if (flag == 'l') printf("\n");column+=yyleng;}
<COMENTARIO>"\n"|"\r"|"\r\n"			{line++;column=1;}
<COMENTARIO>.					{column+=yyleng;}
<COMENTARIO><<EOF>>				{printf("Line %d, Column %d: unterminated comment\n",aux_line,aux_column); BEGIN 0;}

"\""						{BEGIN STRING; if (flag == 'l') printf("STRLIT("); aux_line = line; aux_column = column; column+=yyleng;}
<STRING>"\\r"|"\n"|"\\t"|"\\f"|\\\\|\\\"	{if (flag == 'l') printf("%s", yytext);}
<STRING>\\[^{num}]				{printf("Line %d, column %d: invalid escape sequence\n",line,column); column+=yyleng;}
<STRING>"\n"|"\r"|"\r\n"			{BEGIN 0; printf("Line %d, column %d: unterminated string literal\n",aux_line,aux_column); line++;column = 1;}
<STRING>"\""					{BEGIN 0; emit_semicolon = 1; if (flag == 'l') printf(")\n");column+=yyleng;}
<STRING><<EOF>>					{printf("Line %d, Column %d: unterminated string literal\n",aux_line,aux_column); BEGIN 0;}
<STRING>.					{if (flag == 'l') printf("%s", yytext);}

{whitespace}					{column++;}
"\n"|"\r\n"|"\r"				{if (flag == 'l' && emit_semicolon == 1) printf("SEMICOLON\n"); emit_semicolon = 0; line++;column=1;}
;						{ emit_semicolon = 0; if (flag == 'l') printf("SEMICOLON\n");column+=yyleng;}
_						{ emit_semicolon = 0; if (flag == 'l') printf("BLANKID\n");column+=yyleng;}
package						{ emit_semicolon = 0; if (flag == 'l') printf("PACKAGE\n");column+=yyleng;}
return						{ emit_semicolon = 1; if (flag == 'l') printf("RETURN\n");column+=yyleng;}
&&						{ emit_semicolon = 0; if (flag == 'l') printf("AND\n");column+=yyleng;}
=						{ emit_semicolon = 0; if (flag == 'l') printf("ASSIGN\n");column+=yyleng;}
"*"						{ emit_semicolon = 0; if (flag == 'l') printf("STAR\n");column+=yyleng;}
","						{ emit_semicolon = 0; if (flag == 'l') printf("COMMA\n");column+=yyleng;}
"/"						{ emit_semicolon = 0; if (flag == 'l') printf("DIV\n");column+=yyleng;}
"=="						{ emit_semicolon = 0; if (flag == 'l') printf("EQ\n");column+=yyleng;}
">="						{ emit_semicolon = 0; if (flag == 'l') printf("GE\n");column+=yyleng;}
">"						{ emit_semicolon = 0; if (flag == 'l') printf("GT\n");column+=yyleng;}
"{"						{ emit_semicolon = 0; if (flag == 'l') printf("LBRACE\n");column+=yyleng;}
"<="						{ emit_semicolon = 0; if (flag == 'l') printf("LE\n");column+=yyleng;}
"("						{ emit_semicolon = 0; if (flag == 'l') printf("LPAR\n");column+=yyleng;}
"["						{ emit_semicolon = 0; if (flag == 'l') printf("LSQ\n");column+=yyleng;}
"<"						{ emit_semicolon = 0; if (flag == 'l') printf("LT\n");column+=yyleng;}
"-"						{ emit_semicolon = 0; if (flag == 'l') printf("MINUS\n");column+=yyleng;}
"%"						{ emit_semicolon = 0; if (flag == 'l') printf("MOD\n");column+=yyleng;}
"!="						{ emit_semicolon = 0; if (flag == 'l') printf("NE\n");column+=yyleng;}
"!"						{ emit_semicolon = 0; if (flag == 'l') printf("NOT\n");column+=yyleng;}
"||"						{ emit_semicolon = 0; if (flag == 'l') printf("OR\n");column+=yyleng;}
"+"						{ emit_semicolon = 0; if (flag == 'l') printf("PLUS\n");column+=yyleng;}
"}"						{ emit_semicolon = 1; if (flag == 'l') printf("RBRACE\n");column+=yyleng;}
")"						{ emit_semicolon = 1; if (flag == 'l') printf("RPAR\n");column+=yyleng;}
"]"						{ emit_semicolon = 1; if (flag == 'l') printf("RSQ\n");column+=yyleng;}
else						{ emit_semicolon = 0; if (flag == 'l') printf("ELSE\n");column+=yyleng;}
for						{ emit_semicolon = 0; if (flag == 'l') printf("FOR\n");column+=yyleng;}
if						{ emit_semicolon = 0; if (flag == 'l') printf("IF\n");column+=yyleng;}
var						{ emit_semicolon = 0; if (flag == 'l') printf("VAR\n");column+=yyleng;}
int						{ emit_semicolon = 0; if (flag == 'l') printf("INT\n");column+=yyleng;}
float32						{ emit_semicolon = 0; if (flag == 'l') printf("FLOAT32\n");column+=yyleng;}	
bool						{ emit_semicolon = 0; if (flag == 'l') printf("BOOL\n");column+=yyleng;}
string						{ emit_semicolon = 0; if (flag == 'l') printf("STRING\n");column+=yyleng;}
fmt"."Println					{ emit_semicolon = 0; if (flag == 'l') printf("PRINT\n");column+=yyleng;}
strconv"."Atoi					{ emit_semicolon = 0; if (flag == 'l') printf("PARSEINT\n");column+=yyleng;}
func						{ emit_semicolon = 0; if (flag == 'l') printf("FUNC\n");column+=yyleng;}
os\.Args					{ emit_semicolon = 0; if (flag == 'l') printf("CMDARGS\n");column+=yyleng;}
{reserved}					{ emit_semicolon = 0; if (flag == 'l') printf("RESERVED\n");column+=yyleng;}
{id}						{ emit_semicolon = 1; if (flag == 'l') printf("ID(%s)\n", yytext);column+=yyleng;}
{intlit}					{ emit_semicolon = 1; if (flag == 'l') printf("INTLIT(%s)\n", yytext);column+=yyleng;}
{reallit}					{ emit_semicolon = 1; if (flag == 'l') printf("REALLIT(%s)\n", yytext);column+=yyleng;}
.						{printf("Line %d, column %d: illegal character (%c)\n",line,column,*yytext);column++;}


%%
int main(int argc, char** argv)
{
    if(argc > 1 && argv[1][0] == '-') {
        flag = argv[1][1]; //flag is 'l'?
    }
    
    yylex();
    return 0;
}

int yywrap()
{
	return 1;
}

