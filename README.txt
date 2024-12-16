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
