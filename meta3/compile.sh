lex gocompiler.l
yacc -d -v gocompiler.y
clang-3.8 -g -Wall -Wno-unused-function -o gocompiler y.tab.c lex.yy.c ast.c table.c
