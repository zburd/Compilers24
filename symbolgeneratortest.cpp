#include "symbolgenerator.h"
using namespace std;

int main(){
	string filename = "parserout.txt";
	ParseTreeNode* tree = buildParseTreeFromFile (filename);
	printParseTree (tree);
	
	return 0;
}
