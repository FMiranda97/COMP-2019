%X COMENTARIO
num			[0-9]+
hexa			[a-fA-f]+
letra			[a-zA-Z]+
exp			(e|E)("+"|"-")?{num}+
whitespace		" "|"\n"|"\t"
comment			"//".*
id			(_|{letra})(_|{letra}|{num})*
intlit			{num}|0(x|X)({num}|{hexa})*
reallit			{num}+"."{num}*{exp}?|{num}*{exp}|{num}*"."{num}+{exp}?
strlit			\".*\"
reserved		"++"|"--"|break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var	
%%	
"/*"						{BEGIN COMENTARIO;}
<COMENTARIO>[^"/*"]				{;}
<COMENTARIO>"*/"				{BEGIN 0; printf("\n");}
{whitespace}|{comment}				{;} \
;						{printf("SEMICOLON\n");}
_						{printf("BLANKID\n");}
package						{printf("PACKAGE\n");}
return						{printf("RETURN\n");}
return"\n"					{printf("RETURN\nSEMICOLON\n");}
&&						{printf("AND\n");}
=						{printf("ASSIGN\n");}
"*"						{printf("STAR\n");}
,						{printf("COMMA\n");}
"/"						{printf("DIV\n");}
==						{printf("EQ\n");}
>=						{printf("GE\n");}
>						{printf("GT\n");}
"{"						{printf("LBRACE\n");}
"<="						{printf("LE\n");}
"("						{printf("LPAR\n");}
"["						{printf("LSQ\n");}
"<"						{printf("LT\n");}
"-"						{printf("MINUS\n");}
"%"						{printf("MOD\n");}
!=						{printf("NE\n");}
!						{printf("NOT\n");}
"||"						{printf("OR\n");}
"+"						{printf("PLUS\n");}
"}"						{printf("RBRACE\n");}
")"						{printf("RPAR\n");}
"]"						{printf("RSQ\n");}
"}""\n"						{printf("RBRACE\nSEMICOLON\n");}
")""\n"						{printf("RPAR\nSEMICOLON\n");}
"]""\n"						{printf("RSQ\nSEMICOLON\n");}
else						{printf("ELSE\n");}
for						{printf("FOR\n");}
if						{printf("IF\n");}
var						{printf("VAR\n");}
int						{printf("INT\n");}
float32						{printf("FLOAT32\n");}	
bool						{printf("BOOL\n");}
string						{printf("STRING\n");}
fmt"."Println					{printf("PRINT\n");}
strconv"."Atoi					{printf("PARSEINT\n");}
func						{printf("FUNC\n");}
os"."Args					{printf("CMDARGS\n");}
{reserved}					{printf("RESERVED\n");}
{id}						{printf("ID(%s)\n", yytext);}
{id}"\n"					{printf("ID(%.*s)\nSEMICOLON\n", yyleng-1, yytext);}
{intlit}					{printf("INTLIT(%s)\n", yytext);}
{intlit}"\n"			{printf("INTLIT(%.*s)\nSEMICOLON\n", yyleng-1, yytext);}
{reallit}					{printf("REALLIT(%s)\n", yytext);}
{reallit}"\n"					{printf("REALLIT(%.*s)\nSEMICOLON\n", yyleng-1, yytext);}
{strlit}					{printf("STRLIT(%s)\n", yytext);}
{strlit}"\n"					{printf("STRLIT(%.*s)\nSEMICOLON\n", yyleng-1, yytext);}
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

