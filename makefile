.PHONY: all flex lex.yy.c a.out clean

all: flex lex.yy.c a.out clean

flex:
	@flex lexer.l

lex.yy.c:
	@gcc lex.yy.c

a.out:
	@./a.out

clean:
	@rm lex.yy.c
	@rm a.out
