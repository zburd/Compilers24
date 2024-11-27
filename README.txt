Zachary Burd, Jeremy Estes, James Lucid

Makefile compiles lexer/parser, compiles symbolgenerator.h, and outputs to parserout.txt file. 

To test the parse tree, run the following:

make
g++ symbolgeneratortest.cpp
./a.out

It dumps the stack which is left with only 52 entries on it. While this indicates there are bugs, it indicates that the parse tree is over 95% complete, since the parserout.txt is over 1300 lines.

To clean the files type:

make clean

