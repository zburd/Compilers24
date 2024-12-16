Zachary Burd, Jeremy Estes and James Lucid

# F24 Language Compiler

To compile, run:
make

Makefile compiles codegenerator and parser into one program. The executable is named f24compiler.

To run with a debugger like gdb, run:
make debug

To use, run:
./f24compiler <filename> <options>

Options are optional. To simply compile an f24 file, do not specify options.

To get help for options, run:
./f24compiler -help

Other options include the following:
-parseonly: parses, generates the parserout.txt file
-treedebug: parses, generates the parserout.txt file, and prints the parse tree
-debugextreme: parses, prints debug info to the screen, and then prints the parse tree and remaining stack from tree generation
-vardebug: prints out the variable container as assembled from the parse tree


To clean the files type:
make clean



What works: 
Lexer, parser, parse tree, and symbolgenerator completely work
Debug flags for code generation work
The direct linking of all pieces in the code generator works
Syntax error handling work
Extended variable table works
Math solver should work, but isn't called to test
Register allocation should work, but isn't called to test

What doesn't work:
Loops, function definition, and if statement control flow unimplemented
Function call control flow unimplemented
Identifier referencing is unimplemented
