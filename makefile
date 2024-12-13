.PHONY: all debug normalcompile run clean

all: normalcompile

debug:
	@bison -d parser.y
	@flex lexer.l
	@g++ parser.tab.c codegenerator.cpp -ll -lm -g -DDEBUG -o f24compiler

normalcompile:
	@bison -d parser.y
	@flex lexer.l
	@g++ parser.tab.c codegenerator.cpp -ll -lm -g -o f24compiler

run:
	@./f24compiler mg.f24

clean:
	@rm -f lex.yy.c
	@rm -f parser.tab.c
	@rm -f parser.tab.h
	@rm -f parserout.txt
	@rm -f f24compiler
	@rm -f yourmain.h
