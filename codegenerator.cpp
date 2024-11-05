#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stack>
#include "symbolgenerator.h"


using std::vector;
using std::string;
using std::stack;
using std::ifstream;
using std::cout;



int main() {
    //todo, link up the flex and bison stuff here and also have some char* argv instead of hardcoded filenames
    
    string filename = "parserout.txt";

	ParseTreeNode* tree = buildParseTreeFromFile (filename);
	//step one, check for it being a program

	printParseTree (tree);

	if (tree->name == "Program"){
		// Start walking through the program and declaring functions
		//declareFunction (tree -> children[0]);
	}
	else { 
	    cout << "Syntax error: Programs must start with program keyword.\n"; 
	    return 0; //probably should use an error code here along with cerr
	}

    //step 2: evaluate child nodes of program
    vector<ParseTreeNode*> firstclass = tree->getChildren();
    
    //if this is empty we have an empty program, this is invalid
    if (firstclass.empty()) {
        cout << "Syntax error: Program must not be empty.\n"; 
	    return 0; 
    }
    
    //with these checks satisfied, we can begin to process the functions and procedures inside of program
    
    //variables are NOT okay to have here yet!
    for (int i = 0; i < firstclass.size(); i++)
    {
        
        if (firstclass[i]->isVariable()) {
            cout << "Syntax error: Only functions and procedures are allowed inside of program declaration.\n";
            return 0;
        }
    }
    
    //then, we check to make sure that one and ONLY one of these functions is a main, if not, this is invalid
    
    
    int maincounter = 0;
    
    ParseTreeNode* mainfuncnode;
    
    for (int i = 0; i < firstclass.size(); i++)
    {
        
        if (firstclass[i]->data == "main") 
            {
                maincounter++;
                mainfuncnode = firstclass[i];
            }
    }
    if (maincounter == 0) {
        cout << "Syntax error: No main function.\n";
        return 0;
    } else if (maincounter > 1) {
        cout << "Syntax error: Multiple main functions. Remove one.\n";
        return 0;
    }
    
    //next, we now know we have a singular main function. We also have the node that contains this special function. We start building code from here.
    
    
    
	//cout << "\n//Done inside program\n";
	
    printf("int yourmain()\n{");
    int vars = 0;//int vars = function that count number of variables + 1
    printf("    SR -= %d;\n", vars);
    printf("    FR = SR;\n");
    int varsi = 0;//int varsi = function that count number of int variables + 1
    printf("    FR += %d;\n", varsi);

    //info storage section  
    for(int i; i < varsi; i++){//this is just for ints
        int value = 0;//int value = function that gets the value of int
        printf("    R[1] = %d;\n", value);
        printf("    F24Time += (1);\n");
        printf("    mem[SR+n] = R[1];\n");
        printf("    F24Time += (20+1);\n");
    }

    //print section
    int prints = 0;//int prints = function to find prints in tree
    for(int i; i < varsi; i++){
        //if(print = int_print){printf("print_int(Mem[SR]);\n");}
        //if(print = print_string){printf("print_string(Mem[SR]);\n");}
        //if(print = print_double){printf("print_double(Mem[SR]);\n");}
        printf("    print_int(Mem[SR]);\n");
    }
    printf("    SR += %d;\n", vars);
    printf("    return 0;\n");
    printf("}");
	
    return 0;

}
