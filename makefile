.PHONY: all flex lex.yy.c a.out clean

all: flex

debug:
	@bison -d parser.y
	@flex lexer.l
	@g++ parser.tab.c codegenerator.cpp -lm -g -DDEBUG -o f24compiler
	@./f24compiler mg.f24

normalcompile:
	@bison -d parser.y
	@flex lexer.l
	@g++ parser.tab.c codegenerator.cpp -lm -g -o f24compiler
	@./f24compiler mg.f24

flex:
	@bison -d parser.y
	@flex lexer.l
	@g++ parser.tab.c codegenerator.cpp -lm -g -o f24compiler
	@./f24compiler mg.f24

clean:
	@rm -f lex.yy.c
	@rm -f parser.tab.c
	@rm -f parser.tab.h
	@rm -f parserout.txt
	@rm -f f24compiler
	@rm -f yourmain.h
