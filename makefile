.PHONY: all flex lex.yy.c a.out clean

all: flex lex.yy.c a.out

flex:
	@bison -d simpleparser.y
	@flex lexer.l

lex.yy.c:
	@gcc simpleparser.tab.c lex.yy.c -o simpleparser -lm

a.out:
	@./simpleparser < tiny_example_2.f24

clean:
	@rm lex.yy.c
	@rm simpleparser.tab.c
	@rm ./simpleparser
	@rm simpleparser.tb.h
