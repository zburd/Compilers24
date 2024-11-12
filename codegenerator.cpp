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

        ParseTreeNode* firstChild;

    public:
        //constructor for parsetreenode input
        varContainer(ParseTreeNode &PT) {
            dtype = PT.dtype;
            data = PT.data;
            name = PT.name;
            owner = PT.belongsTo();
            firstChild = PT.getChildren()[0];
        }
        //constructor for input of other varcontainers
        varContainer(const varContainer &NT) {
            dtype = NT.getType();
            data = NT.getData();
            name = NT.getName();
            owner = NT.ownsThis();
            firstChild = NT.getFirstChild();
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
        ParseTreeNode* getFirstChild() const{
            return firstChild;
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

int lineCounter(ParseTreeNode &PT){
    int counter = 0;
    vector<ParseTreeNode*> children = PT.getChildren();
    for(int i = 0; i < children.size(); i++){
        if(children[i]->name == "Assign"){
            lineInfo.push_back(varContainer(*children[i]));
            counter += 1 + lineCounter(*children[i]);
        }
        else if(children[i]->name == "Inside_Print" ){
            lineInfo.push_back(varContainer(*children[i]));
            counter += 1 + lineCounter(*children[i]);
        }
        else if(children[i]->name == "Inside_Function_Call" ){
            //lineInfo.push_back(varContainer(*children[i]->children[0]));
            counter += 1 + lineCounter(*children[i]);
        }
        else if(children.size() != i){
            counter += lineCounter(*children[i]);
        }
    }
    return counter;
}

int varFinder(vector<varContainer> NT, string var){
    for(int i = 0; i < NT.size(); i++){
        if(var == NT[i].getData()){
            return i;
        }
    }
    return -1;
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

    ofstream MyFile("yourmain.h");

    MyFile << "int yourmain()\n{\n    // Stack adjustment\n";
    int vars = varCounter(*tree);
    MyFile << "    SR -= " << vars << ";\n";
    MyFile << "    FR = SR;\n";
    int varsi = intVarCounter(*tree);
    MyFile << "    FR += " << varsi << ";\n";

    int codeLines = lineCounter(*tree);
    for(int i = 0; i < codeLines; i++){
        string expression = lineInfo[i].getName();
        //info storage section
        if(expression == "Assign" && lineInfo[i].getFirstChild()->name == "Iconstant"){
            string Ivalue = lineInfo[i].getFirstChild()->data;//int value = function that gets the value of int:
            MyFile << "    // Variable Section\n    R[1] = " << Ivalue << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    Mem[SR+" << varFinder(varInfo, lineInfo[i].getData()) << "] = R[1];\n";
            MyFile << "    F24_Time += (20+1);\n";
        }
        else if(expression == "Assign" && lineInfo[i].getFirstChild()->name == "Dconstant"){
            string Dvalue = "here";//lineInfo[i].getFirstChild()->data;//function that gets the value of double
            MyFile << "    F[1] = " << Dvalue << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    FMem[FR+" << varFinder(varInfo, lineInfo[i].getData()) << "] = F[1];\n";
            MyFile << "    F24_Time += (20+2);\n";
        }
        else if(expression == "Assign" && lineInfo[i].getFirstChild()->name == "Sconstant"){
            //string Svalue = "here";//function that gets the string
            MyFile << "    SMem[FR+" << i << "] = F[1];\n";
            MyFile << "    F24_Time += (20+1);\n";
        }
        else if(expression == "Inside_Print"){
            if(lineInfo[i].getFirstChild()->name == "PrintI"){MyFile << "    // Print Section\n    print_int(Mem[SR+" << varFinder(varInfo, lineInfo[i].getFirstChild()->data) << "]);\n";}
            if(lineInfo[i].getFirstChild()->name == "PrintD"){MyFile << "    // Print Section\n    print_double(FMem[FR]);\n";}
            if(lineInfo[i].getFirstChild()->name == "PrintS"){MyFile << "    // Print Section\n    print_string("<< lineInfo[i].getFirstChild()->data <<");\n";}
        }

    }
    MyFile << "    // Stack adjustment\n    SR += " << vars << ";\n";
    MyFile << "    return 0;\n";
    MyFile << "}";
    MyFile.close();

    return 0;

}

