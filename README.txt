Zachary Burd and Jeremy Estes

Makefile is work in progress.

To compile and use lexer individually:

bison -d simpleparser.y
flex lexer.l
gcc simpleparser.tab.c lex.yy.c -o simpleparser -lm
./simpleparser < <insert file to parse here>

or run the makefile by running:

make

To clean the files type:

make clean

This lexes out the file. lexer.l and uses the parser simpleparser.y to parse.
