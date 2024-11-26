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
				else if (name == "Function" || name == "Procedure") {dtype=3;}
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
		//stuff for scope checking
		bool isChild()
		{
		    if (parent != nullptr) return true;
		    else return false;
		}
        string belongsTo()
        {
            if (this->isChild()) return parent->name;
            else return "Root node";
        }
        ParseTreeNode* getParent()
        {
            return parent;
            //this will not check for errors or null ptrs, use the isChild function for that
            //basically, something like 'if ischild then getparent'
        }
        vector<ParseTreeNode*> getChildren()
        {
            return children; 
        }
       //this is for arithmetic stuff and ONLY for variables!
       //see if you can do this for functions too maybe
       
};

bool isTypeKeyword (string cname) {
	return (cname == "K_INTEGER" || cname == "K_DOUBLE" || cname == "K_STRING");
}

bool isParentInside (ParseTreeNode* parent, ParseTreeNode* child) {
	// This function handles all the "Inside_" parse tree functions to clean up the code.
	string pname = parent -> name;
	string cname = child -> name;


	if ( pname == "Inside_Assign" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1: 
				return (cname.substr(0, 7) == "Assign_");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Declare" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1: 
				return (cname.substr(0,8) == "Declare_");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Read" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1: 
				return (cname.substr(0,4)=="Read");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Print" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1: 
				return (cname == "PrintI" || 
						cname == "PrintD" || 
						cname == "PrintS");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_If" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1:
				return (cname.substr(0, 3) == "If_");
			case 2:
				return (cname.substr(0, 10) == "Condition_");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Do" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1:
				return (cname == "Do_Once"||cname == "Do_More");
			case 2:
				return (cname == "LoopParam" || cname == "LoopParam_Conditional");
			case 3:
				return (cname == "Do_Until"||cname == "Do_While"||cname == "Do_For");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Function_Call" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1:
				return (cname == "Inner_Function_Parameter" || cname == "Inner_Function_Parameters");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Function_Declare" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1:
				return (cname.substr(0, 7) == "Inside_");
			case 2:
				return (cname.substr(0,10) == "Parameters");
			case 3:  
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Procedure_Declare" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1:
				return (cname.substr(0, 7) == "Inside_");
			case 2:
				return (cname.substr(0,10) == "Parameters");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Return_Item" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 5) == "Item_");
			default:
				return false;
		}
	}
	else if ( pname == "Inside_Increment_item" || pname == "Inside_Decrement_item") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			default:
				return false;
		}
	}
	else { return false; }
}


bool isParentIf (ParseTreeNode* parent, ParseTreeNode* child) {
	string pname = parent -> name;
	string cname = child -> name;
	if ( pname == "If_More" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			default:
				return false;
		}
	}
	// Will need to be changed, should be If_More_Else_Once
	else if ( pname == "If_More_Else" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
		//	Swap the above to case 1, and set this to the new case 0 to swap
		//	case 0: 
		//		return (cname.substr(0, 5) == "Once_");
			default:
				return false;
		}
	}
	else if ( pname == "If_More_Else_More" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1: 
				return (cname.substr(0, 7) == "Inside_");
			default:
				return false;
		}
	}
	else if ( pname == "If_Once" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 5) == "Once_");
			default:
				return false;
		}
	}
	// Will need to be changed, should be If_Once_Else_Once
	else if ( pname == "If_Once_Else" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 5) == "Once_");
		//	case 1: 
		//		return (cname.substr(0, 5) == "Once_");
			default:
				return false;
		}
	}
	else if ( pname == "If_Once_Else_More" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Inside_");
			case 1: 
				return (cname.substr(0, 5) == "Once_");
			default:
				return false;
		}
	}
	else { return false; }
}

bool isParentOnce (ParseTreeNode* parent, ParseTreeNode* child) {
	string pname = parent -> name;
	string cname = child -> name;

	if (pname == "Once_Inside_Declare" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 8) == "Declare_");
			default:
				return false;
		}
	}
	else if (pname == "Once_Inside_Assign" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 7) == "Assign_");
			default:
				return false;
		}
	}
	else if (pname == "Once_Inside_Print" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 5) == "Print");
			default:
				return false;
		}
	}
	else if (pname == "Once_Inside_Read" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 4) == "Read");
			default:
				return false;
		}
	}
	else if (pname == "Once_Inside_Function_Call" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname == "Inner_Function_Parameter" || cname == "Inner_Function_Parameters");
			default:
				return false;
		}
	}
	else if ( pname == "Once_Inside_Do" ) { 
		switch (parent -> children.size()){
			case 0:
				return (cname == "Do_Once"||cname == "Do_More");
			case 1:
				return (cname == "LoopParam" || cname == "LoopParam_Conditional");
			case 2:
				return (cname == "Do_Until"||cname == "Do_While"||cname == "Do_For");
			default:
				return false;
		}
	}
	else if (pname == "Once_Return_Item" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 5) == "Item_");
			default:
				return false;
		}
	}
	else { return false; }
}
bool isParentCondition (ParseTreeNode* parent, ParseTreeNode* child) {
	string pname = parent -> name;
	string cname = child -> name;

	if (pname == "Condition_Only" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,5) == "Item_");
			case 1: 
				return (cname == "CondEq");
			case 2: 
				return (cname.substr(0,5) == "Item_");

			default:
				return false;
		}
	}
	else if (pname == "Condition_Not" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0, 10) == "Condition_");
			default:
				return false;
		}
	}
	else if (pname == "Condition_Or" || pname == "Condition_And") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,5) == "Item_");
			case 1: 
				return (cname == "CondEq");
			case 2: 
				return (cname.substr(0,5) == "Item_");
			case 3: 
				return (cname.substr(0, 10) == "Condition_");
			default:
				return false;
		}
	}
	else { return false; }
}

bool isParentPrint (ParseTreeNode* parent, ParseTreeNode* child) {
	string pname = parent -> name;
	string cname = child -> name;

	if (pname.substr(0, 5)== "Print"){
		switch (parent ->children.size()){
			case 0:
				return (cname.substr(0, 5)== "Item_");
			default:
				return false;
		}
	}
	else { return false; }
}

bool isParentItem (ParseTreeNode* parent, ParseTreeNode* child) {
	string pname = parent -> name;
	string cname = child -> name;

	if (pname== "Item_Assign"){
		switch (parent ->children.size()){
			case 0:
				return (cname.substr(0,5)== "Item_");
			default:
				return false;
		}
	}
	else if (pname== "Item_Assign_Array"){
		switch (parent ->children.size()){
			case 0:
				return (cname.substr(0,5)== "Item_");
			case 1:
				return (cname.substr(0,6)== "MathI_");
			default:
				return false;
		}
	}
	else if (pname== "Item_Math_Equation"){
		switch (parent ->children.size()){
			case 0:
				return (cname.substr(0,6)== "MathI_");
			default:
				return false;
		}
	}
	else { return false; }
}
bool isParentAssign (ParseTreeNode* parent, ParseTreeNode* child) {
	string pname = parent -> name;
	string cname = child -> name;

	if (pname.substr(0,11)== "Assign_Item"){
		switch (parent ->children.size()){
			case 0:
				return (cname.substr(0,5)== "Item_");
			default:
				return false;
		}
	}
	else if (pname.substr(0,12)== "Assign_Array"){
		switch (parent ->children.size()){
			case 0:
				return (cname.substr(0,5)== "Item_");
			case 1:
				return (cname.substr(0,5)== "Math_");
			default:
				return false;
		}
	}
	else if (pname== "Assign_Identifier_Array"){
		switch (parent ->children.size()){
			case 0:
				return (cname.substr(0,5)== "Math_");
			default:
				return false;
		}
	}
	else { return false; }
}

bool isParentMath (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;

	if (pname == "Math_Equation") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,6) =="MathI_");
			default:
				return false;
		}
	}
	else { return false; }
}
bool isParentMathI (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;
	
	if (pname == "MathI_Plus" || pname == "MathI_Minus") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,7) =="MathI2_");
			case 1: 
				return (cname.substr(0,6) =="MathI_");
			default:
				return false;
		}
	}
	else if (pname == "MathI_to_I2") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,7) =="MathI2_");
			default:
				return false;
		}
	}
	else { return false; }
}
bool isParentMathI2 (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;
	
	if (pname == "MathI2_Multiply" || pname == "MathI2_Divide"|| pname == "MathI2_Mod") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,7) =="MathI3_");
			case 1: 
				return (cname.substr(0,7) =="MathI2_");
			default:
				return false;
		}
	}
	else if (pname == "MathI2_to_I3") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,7) =="MathI3_");
			default:
				return false;
		}
	}
	else { return false; }
}
bool isParentMathI3 (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;
	
	if (pname == "MathI3_Paren_Math") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,6) =="MathI_");
			default:
				return false;
		}
	}
	else if (pname == "MathI3_Array" || pname == "MathI3_Negative_Array") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,6) =="MathI_");
			default:
				return false;
		}
	}
	else if (pname == "MathI3_Function_Call") { 
		switch (parent -> children.size()){
			case 0: 
				return (cname == "Inner_Function_Parameter" || cname == "Inner_Function_Parameters");
			default:
				return false;
		}
	}
	else { return false; }
}

bool isParentDo (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;

	if ( pname == "Do_Once" ){
		switch (parent -> children.size()){
			case 0:
				return cname.substr(0,5)=="Once_";
			default:
				return false;
		}
	}
	else if (pname=="Do_More"){
		switch (parent -> children.size()){
			case 0:
				return cname.substr(0,7)=="Inside_";
			default:
				return false;
		}
	}
	else { return false; }

}
bool isParentDeclare (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;


	if ( pname == "Declare_One" ){
		switch (parent -> children.size()){
			case 0:
				return cname.substr(0,7)=="Assign_";
			case 1:
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else if ( pname == "Declare_Done" ){
		switch (parent -> children.size()){
			case 0:
				return cname.substr(0,7)=="Assign_";
			default:
				return false;
		}
	}
	else if ( pname == "Declare_More" ){
		switch (parent -> children.size()){
			case 0:
				return cname.substr(0,7)=="Assign_";
			case 1:
				return (cname=="Declare_More" || cname=="Declare_Done");
			default:
				return false;
		}
	}
	else if ( pname == "Declare_Type_More" ){
		switch (parent -> children.size()){
			case 0:
				return cname.substr(0,7)=="Assign_";
			case 1:
				return (cname=="Declare_More" || cname=="Declare_Done");
			case 2: 
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else { return false;}
}
bool isParentParameters (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;

	if ( pname == "Parameters_More" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,10) == "Parameters");
			case 1: 
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else if ( pname == "Parameters" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname == "Parameters_Empty");
			case 1: 
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else if ( pname == "Parameters_More_Array" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,10) == "Parameters");
			case 1: 
				return (cname.substr(0,5) == "Math_");
			case 2: 
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else if ( pname == "Parameters_Array" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname == "Parameters_Empty");
			case 1: 
				return (cname.substr(0,5) == "Math_");
			case 2: 
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else { return false; }
}
bool isParentLoopParam (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;

	if ( pname == "LoopParam" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,10) == "Condition_");
			case 1:
				return (cname.substr(0,6) == "MathI_");
			default:
				return false;
		}
	}
	else if ( pname == "LoopParam_Conditional" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,10) == "Condition_");
			default:
				return false;
		}
	}
	else { return false; }
}

bool isParent (ParseTreeNode* parent, ParseTreeNode* child) {
	// stuff for each line type
	if (child == nullptr) {return false;}

	string pname = parent -> name;
	string cname = child -> name;

	if (cname == "Condition_Only") {std::cout << pname << " checked with " << cname << "\n";}


	if ( pname == "Program" && parent->children.size() == 0) { return cname == "Function" || cname == "Procedure"; }
	else if ( pname == "Function" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname=="Function" || cname=="Procedure" || cname=="Function_Empty");
			case 1: 
				return (cname.substr(0, 7) == "Inside_");
			case 2:
				return (cname.substr(0,10) == "Parameters");
			case 3:	 
				return isTypeKeyword(cname);
			default:
				return false;
		}
	}
	else if ( pname == "Procedure" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname=="Function" || cname=="Procedure" || cname=="Function_Empty");
			case 1: 
				return (cname.substr(0, 7) == "Inside_");
			case 2:
				return (cname.substr(0,10) == "Parameters");
			default:
				return false;
		}
	}
	else if (pname.substr(0, 7) == "Inside_") { return isParentInside(parent, child); }
	else if (pname.substr(0, 3) == "If_") { return isParentIf(parent, child); }
	else if (pname.substr(0, 5) == "Once_") { return isParentOnce(parent, child); }
	else if (pname.substr(0, 10) == "Condition_") { return isParentCondition(parent, child); }
	else if (pname.substr(0, 5)== "Print") { return isParentPrint(parent, child); }
	else if (pname.substr(0, 5)== "Item_") { return isParentItem(parent, child); }
	else if (pname.substr(0, 7)== "Assign_") { return isParentAssign(parent, child); }

	else if (pname.substr(0, 5)== "Math_") { return isParentMath(parent, child); }
	else if (pname.substr(0, 6)== "MathI_") { return isParentMathI(parent, child); }
	else if (pname.substr(0, 7)== "MathI2_") { return isParentMathI2(parent, child); }
	else if (pname.substr(0, 7)== "MathI3_") { return isParentMathI3(parent, child); }
	

	else if (pname.substr(0, 3)== "Do_") { return isParentDo(parent, child); }

	else if (pname.substr(0, 8)== "Declare_") { return isParentDeclare(parent, child); }

	else if (pname.substr(0, 10)== "Parameters") { return isParentParameters(parent, child); }
	else if (pname.substr(0, 9)== "LoopParam") { return isParentLoopParam(parent, child); }



	else if ( pname == "Inner_Function_Parameters" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname == "Inner_Function_Parameter" || cname == "Inner_Function_Parameters");
			case 1:  
				return (cname.substr(0,5) == "Item_");
			default:
				return false;
		}
	}
	else if ( pname == "Inner_Function_Parameter" ) { 
		switch (parent -> children.size()){
			case 0: 
				return (cname.substr(0,5) == "Item_");
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
				//std::cout << "Added " << nodeStack.top()->name << " to " <<newNode->name<<"\n";
				nodeStack.pop();
			} else {break;}
		}
		nodeStack.push(newNode);
	}

	if (!nodeStack.empty()){
		finalTree = nodeStack.top();
		nodeStack.pop();
	}

	// For debugging only, the stack should be empty now.
	if (!nodeStack.empty()){
		std::cout << "Top unpopped node after final tree is removed: " << nodeStack.top()->name << "\n";
		std::cout << "Stack size remaining:                        : " << nodeStack.size() << "\n";
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

	while (walknode->children[3]->name != "Inside_Empty"){
		walknode = walknode->children[2];
		if (walknode->name == "Inside_Declare") {
			//TODO: Put the variables on the stack here
			//Make sure to change stacksize so it properly exits scope when done
		}
	}


	// Reset walknode here, and then go through with all the assigns, prints, and returns
	// At this point, all variables within the function's scope are declared. 
	
	//TODO: Generate code for the other things the function does here.

	//TODO: Generate code to properly decrement the stack here.
	//TODO: Generate a goto statement to go back to where the function was called.
	

	// Handle functions after this one.
	if (ftree->children[0]->name == "Function") {declareFunction(ftree->children[0]);}
	cout << "\n//Done inside function\n";
}

/*void generateCode (ParseTreeNode* ptree){
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
}*/
