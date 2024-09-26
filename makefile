.PHONY: all flex lex.yy.c a.exe clean

.PHONY all flex lex.yy.c a.exe clean

all: flex lex.yy.c a.exe

flex:
	@flex lexer.l

lex.yy.c:
	@gcc lex.yy.c

a.exe:
	@./a.out

clean:
	@rm lex.yy.c
	@rm a.out
