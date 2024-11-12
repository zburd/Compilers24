.PHONY: all flex lex.yy.c a.out clean

all: flex lex.yy.c a.out g++ run

flex:
	@bison -d parser.y
	@flex lexer.l

lex.yy.c:
	@gcc parser.tab.c lex.yy.c -o parser -lm

a.out:
	@./parser < tiny_example_1.f24 > parserout.txt

g++:
	@g++ codegenerator.cpp

run:
	@./a.out

clean:
	@rm lex.yy.c
	@rm parser.tab.c
	@rm ./parser
	@rm parser.tab.h
	@rm parserout.txt
	@rm a.out
	@rm yourmain.h
