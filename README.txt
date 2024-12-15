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

To clean the files type:
make clean