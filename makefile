.PHONY: all flex lex.yy.c a.out clean

all: flex lex.yy.c a.out g++ run

flex:
	@bison -d simpleparser.y
	@flex lexer.l

lex.yy.c:
	@gcc simpleparser.tab.c lex.yy.c -o simpleparser -lm

a.out:
	@./simpleparser < tiny_example_1.f24 > parserout.txt

g++:
	@g++ symbolgenerator.cpp

run:
	@./a.out

clean:
	@rm lex.yy.c
	@rm simpleparser.tab.c
	@rm ./simpleparser
	@rm simpleparser.tab.h
	@rm parserout.txt
	@rm a.out
