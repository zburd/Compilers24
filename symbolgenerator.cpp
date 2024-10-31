#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stack>


using std::vector;
using std::string;
using std::stack;
using std::ifstream;
using std::cout;

class ParseTreeNode {
	public:
		ParseTreeNode* parent;
		vector<ParseTreeNode*> children;

		string name;
		
        int dtype; //this is for data types for variables/functions only! 
        //0 = int, 1 = double, 2 = string, 3 = function, set to -1 if this is some other thing
        
		string data; //Data is stored as string, can be converted later

		// Constructor and destructor. 
		ParseTreeNode (string name, string data = "")
			: name(name), data(data), parent(nullptr) {
				if (name == "Iconstant") { dtype=0;}
				else if (name == "Dconstant") { dtype=1;}
				else if (name == "Sconstant") { dtype=2;}
				else if (name == "Function") {dtype=3;}
				else {dtype = -1;}
		}

		~ParseTreeNode () {
			for (ParseTreeNode* child : children){
				delete child;
			}
		}
		void addChild (ParseTreeNode* child){
			if (child != nullptr){
				child -> parent = this;
				children.insert(children.begin(), child);
			}
		}
		bool isVariable()
		{
		    if (dtype == -1 || dtype > 2) return false;
		    else return true;
		}
		string returnvarType()
		{
		    if (this->isVariable() == false) return "Not a variable.";
		    else if (dtype == 0) return "Integer.";
		    else if (dtype == 1) return "Double";
		    else if (dtype == 2) return "String.";
		    else if (dtype == 3) return "Function.";
		}

};

bool isParent (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;

	if ( pname == "Program" && parent->children.size() == 0) { return cname == "Function"; }
	else if ( pname == "Function" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname=="Function" || cname=="Function_Empty");
			case 1: 
				if (cname.length() > 7) {
					return cname.substr(0,7) == "Inside_";
				}else { return false; }
			case 2: 
				return (cname == "K_INTEGER" || 
						cname == "K_DOUBLE" || 
						cname == "K_STRING");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Declare" ) { 
		switch (parent -> children.size()){
			case 0: 
				if (cname.length() > 7) {
					return cname.substr(0,7) == "Inside_";
				}else { return false; }
			case 1: 
				return (cname == "K_INTEGER" || 
						cname == "K_DOUBLE" || 
						cname == "K_STRING");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Assign" ) { 
		switch (parent -> children.size()){
			case 0: 
				if (cname.length() > 7) {
					return cname.substr(0,7) == "Inside_";
				}else { return false; }
			case 1: 
				return cname == "Assign";
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Print" ) { 
		switch (parent -> children.size()){
			case 0: 
				if (cname.length() > 7) {
					return cname.substr(0,7) == "Inside_";
				}else { return false; }
			case 1: 
				return (cname == "PrintI" || 
						cname == "PrintD" || 
						cname == "PrintS");
			default:
				return false;
		}
	}
	else if ( pname == "Assign" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname == "Iconstant" || 
						cname == "Identifier" ||
						cname == "Dconstant" || 
						cname == "Sconstant");

			default:
				return false;
		}
	}

	else { return false; }
}

ParseTreeNode* buildParseTreeFromFile (string filename) {
	
	// Uses a stack to handle the reverse polish notation format
	stack<ParseTreeNode*> nodeStack;
	string line;

	ParseTreeNode* finalTree = nullptr;

	// Opens up the file
	ifstream file(filename);
	if (!file.is_open()) {
		std::cerr << "Could not open file: " << filename << "\n";
		return nullptr;
	}

	// Reads in the file, pushes each line as a node on the stack
	while (std::getline(file, line)) {

		// make a new node for the data in the line
		ParseTreeNode* newNode = nullptr;
		int pos = line.find(" ");
		if (pos == -1) {newNode = new ParseTreeNode(line);}
		else { newNode = new ParseTreeNode(line.substr(0,pos),line.substr(pos+1)); }
			

		while (!nodeStack.empty()){
			if (isParent(newNode, nodeStack.top())){
				// If the node on the stack is a child of the new node,
				// it is added to the new node and then popped
				newNode -> addChild(nodeStack.top());
				nodeStack.pop();
			} else {break;}
		}
		nodeStack.push(newNode);
	}

	if (!nodeStack.empty()){
		finalTree = nodeStack.top();
		nodeStack.pop();
	}

	// Closes the file
	file.close();
	return finalTree;
}

void printParseTree(ParseTreeNode* tree, int depth = 0) {
    if (tree == nullptr) {
        return;
    }

    // Print the current node with indentation based on depth
    cout << string(depth * 4, ' ') // Indentation (4 spaces per depth level)
         << "Node: " << tree->name 
         << ", Data: " << tree->data 
	 << ", dtype: " << tree->dtype << std::endl;

    // Recursively print each child node
    for (ParseTreeNode* child : tree->children) {
        printParseTree(child, depth + 1);
    }
}

void declareFunction (ParseTreeNode* ftree){
	// Walks through the tree and find all declarations in scope, starting at function

	if (ftree->name != "Function") {
		cout << "Tree is not a function!!!!!\n";
		return;
	}

	ParseTreeNode* walknode = ftree;
	int stacksize = 0; // size of space function takes in stack

	// TODO: Add code to get the return pointer from where the function was called

	while (walknode->children[2]->name != "Inside_Empty"){
		walknode = walknode->children[1];
		if (walknode->name == "Inside_Declare") {
			//TODO: Put the variables on the stack here
			//Make sure to change stacksize so it properly exits scope when done
		}
	}

	// At this point, all variables within the function's scope are declared. 
	
	//TODO: Generate code for the other things the function does here.

	//TODO: Generate code to properly decrement the stack here.
	//TODO: Generate a goto statement to go back to where the function was called.
	

	// Handle functions after this one.
	if (ftree->children[0]->name == "Function") {declareFunction(ftree->children[0]);}
	cout << "\n//Done inside function\n";
}

void generateCode (ParseTreeNode* ptree){
	// Pre-declare the funky string function so we don't have to suffer?
	
	// Symbol tables and variable management is handled in helper functions
	
	if (ptree->name == "Program"){
		// Start walking through the program and declaring functions
		declareFunction (ptree -> children[0]);
	}
	else { cout << "Tree is not a program!!!!!\n"; }

	cout << "\n//Done inside program\n";
}

int main(){
	string filename = "parserout.txt";

	ParseTreeNode* tree = buildParseTreeFromFile (filename);

	printParseTree(tree);

	return 0;
}
