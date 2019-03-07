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
strlit			([^\n\"\r\\])*
id			(_|{letra})(_|{letra}|{num})*
intlit			{num}|0(x|X)({num}|{hexa})*
reallit			{num}+"."{num}*{exp}?|{num}*{exp}|{num}*"."{num}+{exp}?
reserved		"++"|"--"|break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var

%{
int column = 1;
int aux_column;
int line = 1;
int aux_line;
%}

%%

"//"						{BEGIN COMMENT; column+= yyleng;}
<COMMENT>"\n"|"\r"|"\r\n"			{BEGIN 0; line++; column=1;}
<COMMENT>.					{column+=yyleng;}

"/*"						{BEGIN COMENTARIO;aux_column = column;aux_line = line;}
<COMENTARIO>"*/"				{BEGIN 0; printf("\n");column+=yyleng;}
<COMENTARIO>"\n"|"\r"|"\r\n"			{line++;column=1;}
<COMENTARIO>.					{column+=yyleng;}
<COMENTARIO><<EOF>>				{printf("Line %d, Column %d: unterminated comment\n",aux_line,aux_column); BEGIN 0;}

"\""						{BEGIN STRING; printf("BEGIN STRLIT "); aux_line = line; aux_column = column; column+=yyleng;}
<STRING>"\\"					{printf("Line %d, column %d: invalid escape sequence\n",line,column); column+=yyleng;}
<STRING>"\n"|"\r"|"\r\n"			{BEGIN 0; printf("Line %d, column %d: unterminated string literal\n",aux_line,aux_column); line++;column = 1;}
<STRING>"\""					{BEGIN 0; printf(" FINISH STRLIT\n");column+=yyleng;}
<STRING><<EOF>>					{printf("Line %d, Column %d: unterminated string literal\n",aux_line,aux_column); BEGIN 0;}
<STRING>{strlit}				{printf("STRLIT (%s)\n",yytext); column+=yyleng;}	//Not sure disto, vê o strlit em cima

{whitespace}					{column++;}


"\n"|"\r\n"|"\r"				{line++;column=1;}

;						{printf("SEMICOLON\n");column+=yyleng;}
_						{printf("BLANKID\n");column+=yyleng;}
package						{printf("PACKAGE\n");column+=yyleng;}
return						{printf("RETURN\n");column+=yyleng;}
&&						{printf("AND\n");column+=yyleng;}
=						{printf("ASSIGN\n");column+=yyleng;}
"*"						{printf("STAR\n");column+=yyleng;}
","						{printf("COMMA\n");column+=yyleng;}
"/"						{printf("DIV\n");column+=yyleng;}
"=="						{printf("EQ\n");column+=yyleng;}
">="						{printf("GE\n");column+=yyleng;}
">"						{printf("GT\n");column+=yyleng;}
"{"						{printf("LBRACE\n");column+=yyleng;}
"<="						{printf("LE\n");column+=yyleng;}
"("						{printf("LPAR\n");column+=yyleng;}
"["						{printf("LSQ\n");column+=yyleng;}
"<"						{printf("LT\n");column+=yyleng;}
"-"						{printf("MINUS\n");column+=yyleng;}
"%"						{printf("MOD\n");column+=yyleng;}
"!="						{printf("NE\n");column+=yyleng;}
"!"						{printf("NOT\n");column+=yyleng;}
"||"						{printf("OR\n");column+=yyleng;}
"+"						{printf("PLUS\n");column+=yyleng;}
"}"						{printf("RBRACE\n");column+=yyleng;}
")"						{printf("RPAR\n");column+=yyleng;}
"]"						{printf("RSQ\n");column+=yyleng;}
else						{printf("ELSE\n");column+=yyleng;}
for						{printf("FOR\n");column+=yyleng;}
if						{printf("IF\n");column+=yyleng;}
var						{printf("VAR\n");column+=yyleng;}
int						{printf("INT\n");column+=yyleng;}
float32						{printf("FLOAT32\n");column+=yyleng;}	
bool						{printf("BOOL\n");column+=yyleng;}
string						{printf("STRING\n");column+=yyleng;}
fmt"."Println					{printf("PRINT\n");column+=yyleng;}
strconv"."Atoi					{printf("PARSEINT\n");column+=yyleng;}
func						{printf("FUNC\n");column+=yyleng;}
os"."Args					{printf("CMDARGS\n");column+=yyleng;}
{reserved}					{printf("RESERVED\n");column+=yyleng;}
{id}						{printf("ID(%s)\n", yytext);column+=yyleng;}
{intlit}					{printf("INTLIT(%s)\n", yytext);column+=yyleng;}
{reallit}					{printf("REALLIT(%s)\n", yytext);column+=yyleng;}
.						{printf("Line %d, column %d: illegal character (%c)\n",line,column,*yytext);column++;}


%%
int main()
{
	yylex();
	return 0;
}
int yywrap()
{
	return 1;
}
