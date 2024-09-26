<<<<<<< HEAD
.PHONY: all flex lex.yy.c a.exe clean
=======
.PHONY all flex lex.yy.c a.exe clean
>>>>>>> 67b3e09fb511aa0a1b3186454ab7c8605dcd06aa

all: flex lex.yy.c a.exe

flex:
<<<<<<< HEAD
	@flex lexer.l

lex.yy.c:
	@gcc lex.yy.c

a.exe:
	@./a.out

clean:
	@rm lex.yy.c
	@rm a.out
=======
  @flex lexer.l

lex.yy.c:
  @gcc lex.yy.c

a.exe:
  @./a.out

clean:
  @rm lex.yy.c
  @rm a.out
>>>>>>> 67b3e09fb511aa0a1b3186454ab7c8605dcd06aa
