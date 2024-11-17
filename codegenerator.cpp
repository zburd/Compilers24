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
using std::ofstream;

//this class is for variable information, basically a condensed parsetreenode without
//linked list properties, with some other special aspects to make things easier
class varContainer {
    private:
        bool Pointer; //this is probably for stuff that is internal, just in case
        bool Anonymous; //for variables without names, also just in case, eg at the end of return statements?

        int dtype; //same as parsetreenode, 0 = int, 1 = double, 2 = string

        string data;

        string name;

        string owner; //name of function or procedure this variable belongs to

        ParseTreeNode* varTree;

    public:
        //constructor for parsetreenode input
        varContainer(ParseTreeNode &PT) {
            dtype = PT.dtype;
            data = PT.data;
            name = PT.name;
            owner = PT.belongsTo();
            varTree = &PT;
        }
        //constructor for input of other varcontainers
        varContainer(const varContainer &NT) {
            dtype = NT.getType();
            data = NT.getData();
            name = NT.getName();
            owner = NT.ownsThis();
            varTree = NT.getVarTree();
        }

        //getters
        int getType() const{
            return dtype;
        }
        string getName() const{
            return name;
        }
        string getData() const{
            return data;
        }
        ParseTreeNode* getVarTree() const{
            return varTree;
        }
        //assignment operator overload to make our lives easier
        //doesn't do checking though
        varContainer operator= (ParseTreeNode &other) {
            varContainer td(other);
            return td;
        }
        varContainer operator= (varContainer &other) {
            varContainer td(other);
            return td;
        }
        //scope stuff, probably going to need more of this later on
        string ownsThis() const{
            return owner;
        }
        //a sanity check we might need in the future
        bool isNumeric() {
            if (dtype == 0 || dtype == 1) return true;
            else return false;
        }
};

vector<varContainer> lineInfo;
vector<varContainer> varInfo;
vector<varContainer> funcInfo;
ParseTreeNode* empty;

int varCounter(ParseTreeNode &PT){
    int counter = 0;
    vector<ParseTreeNode*> children = PT.getChildren();
    for(int i = 0; i < children.size(); i++){
        if(children[i]->name == "Inside_Declare"){
            varInfo.push_back(varContainer(*children[i]));
            counter += 1 + varCounter(*children[i]);
        }
        else if(children.size() != i){
            counter += varCounter(*children[i]);
        }
    }
    return counter;
}

int intVarCounter(ParseTreeNode &PT){
    int counter = 0;
    vector<ParseTreeNode*> children = PT.getChildren();
    for(int i = 0; i < children.size(); i++){
        if(children[i]->name == "Inside_Declare"){
            if(children[i]->children[0]->name == "K_INTEGER"){
                counter += 1 + intVarCounter(*children[i]);
            }
        }
        else if(children.size() != i){
            counter += intVarCounter(*children[i]);
        }
    }
    return counter;
}

int funcCounter(ParseTreeNode &PT){
    int counter = 0;
    vector<ParseTreeNode*> children = PT.getChildren();
    int size = children.size()-1;
    if(children[size]->name == "Function" || children[size]->name == "Procedure"){
        funcInfo.push_back(varContainer(*children[size]));
        counter += 1 + funcCounter(*children[size]);
    }
    else if(children[size]->name == "Function_Empty"){
        return counter;
    }
    else{
        counter += funcCounter(*children[size]);
    }
    return counter;
}

int vectorFinder(vector<varContainer> NT, string var){
    for(int i = 0; i < NT.size(); i++){
        if(var == NT[i].getData()){
            return i;
        }
    }
    return -1;
}

void lineCounter(ParseTreeNode &PT){
    vector<ParseTreeNode*> children = PT.getChildren();
    int size = children.size()-1;
    if(PT.name == "Function" || PT.name == "Procedure"){size--;}
    string info = children[size]->name;
    if(info == "Inside_Declare" || info == "Inside_Declare_Assign"
        || info == "Inside_Assign" || info == "Inside_Print"
    ){
        lineInfo.push_back(varContainer(*children[size]));
        lineCounter(*children[size]);
    }
    else if(info == "Inside_Function_Call"){
        lineInfo.push_back(varContainer(*children[size]));
        lineCounter(*funcInfo[vectorFinder(funcInfo, children[size]->data)].getVarTree());
    }
}


int mainFinder(vector<varContainer> NT){
    int counter = 0;
    for(int i = 0; i < NT.size(); i++){
        if("main" == NT[i].getData()){
            counter++;
        }
    }
    return counter;
}

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
	    cout << "Syntax error: Programs must start with program keyword.\n" << tree->name;
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


    int functions = funcCounter(*tree);

    int maincounter = mainFinder(funcInfo);



    if (maincounter == 0) {
        cout << "Syntax error: No main function.\n";
        return 0;
    } else if (maincounter > 1) {
        cout << "Syntax error: Multiple main functions. Remove one.\n";
        return 0;
    }

    //next, we now know we have a singular main function. We also have the node that contains this special function. We start building code from here.



	//cout << "\n//Done inside program\n";

    ofstream MyFile("yourmain.h");

    lineCounter(*funcInfo[vectorFinder(funcInfo, "main")].getVarTree());


    for(int i = 0; i < lineInfo.size(); i++){
        cout << "data for line is " << lineInfo[i].getData() << ". name for line is " << lineInfo[i].getName() << ". " << i << "\n";
    }

    MyFile << "int yourmain()\n{\n    // Stack adjustment\n";
    int vars = varCounter(*tree);
    MyFile << "    SR -= " << vars << ";\n";
    MyFile << "    FR = SR;\n";
    int varsi = intVarCounter(*tree);
    MyFile << "    FR += " << varsi << ";\n";

    /*
    for(int i = 0; i < codeLines; i++){
        string expression = lineInfo[i].getName();
        //info storage section
        if(expression == "Assign" && lineInfo[i].getFirstChild()[0]->name == "Iconstant"){
            string Ivalue = lineInfo[i].getFirstChild()[0]->data;//int value = function that gets the value of int:
            MyFile << "    // Variable Section\n    R[1] = " << Ivalue << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    Mem[SR+" << vectorFinder(varInfo, lineInfo[i].getData()) << "] = R[1];\n";
            MyFile << "    F24_Time += (20+1);\n";
        }
        else if(expression == "Assign" && lineInfo[i].getFirstChild()[0]->name == "Dconstant"){
            string Dvalue = "here";//lineInfo[i].getFirstChild()->data;//function that gets the value of double
            MyFile << "    F[1] = " << Dvalue << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    FMem[FR+" << vectorFinder(varInfo, lineInfo[i].getData()) << "] = F[1];\n";
            MyFile << "    F24_Time += (20+2);\n";
        }
        else if(expression == "Assign" && lineInfo[i].getFirstChild()[0]->name == "Sconstant"){
            //string Svalue = "here";//function that gets the string
            MyFile << "    SMem[FR+" << i << "] = F[1];\n";
            MyFile << "    F24_Time += (20+1);\n";
        }
        else if(expression == "Inside_Print"){
            if(lineInfo[i].getFirstChild()[0]->name == "PrintI"){MyFile << "    // Print Section\n    print_int(Mem[SR+" << vectorFinder(varInfo, lineInfo[i].getFirstChild()[0]->data) << "]);\n";}
            if(lineInfo[i].getFirstChild()[0]->name == "PrintD"){MyFile << "    // Print Section\n    print_double(FMem[FR]);\n";}
            if(lineInfo[i].getFirstChild()[0]->name == "PrintS"){MyFile << "    // Print Section\n    print_string("<< lineInfo[i].getFirstChild()[0]->data <<");\n";}
        }

    }
    */
    MyFile << "    // Stack adjustment\n    SR += " << vars << ";\n";
    MyFile << "    return 0;\n";
    MyFile << "}";
    MyFile.close();

    return 0;

}

