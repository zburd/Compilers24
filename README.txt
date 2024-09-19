Zachary Burd and Jeremy Estes

Makefile can be used to comprehensively compile project.

To compile and use lexer individually:

flex lexer.l
g++ lex.yy.c
./a.out < mg.f24

This lexes out the file. hello.l can be used the same way as lexer.l but uses print statements instead of returning tokens. 
