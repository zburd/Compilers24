//miniature macros to make our lives easier. Linked to f24 vm.
//#include "f24.c"
#include <iostream>
#include <vector>
#include <string>
#include <queue>
#include <sstream>
#include <string>

using std::vector;
using std::string;
using std::cout;
using std::endl;
using std::cerr;
using std::queue;
using std::stringstream;

//intermediate structure classes

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
    void setAnonymous(bool a) {
      Anonymous = a;
    }
    void rename(string newName) {
      name = newName;
    }
    void setOwner(string newOwner) {
      owner = newOwner;
    }
    //scope stuff, probably going to need more of this later on
    string ownsThis() const{
        return owner;
    }
    //a sanity check we might need in the future
    bool isNumeric() const {
        if (dtype == 0 || dtype == 1) return true;
        else return false;
    }
    bool isAnonymous() const {
        if (Anonymous) return true;
        else return false;
    }
};
vector<varContainer> lineInfo;
vector<varContainer> varInfo;
vector<varContainer> funcInfo;
vector<varContainer> varTable;

int varCounter(ParseTreeNode &PT){ //doesn't do what the function name implies. change name please -James
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

int vectorNameFinder(vector<varContainer> NT, string var){
    for(int i = 0; i < NT.size(); i++){
        if(var == NT[i].getName()){
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

string findfunc(ParseTreeNode* PT){ //basically, walk back up the parse tree until you find the function
    int tdtype = PT->dtype; //is this already a function?
    if (tdtype == 3) return PT->data;
    else {
        ParseTreeNode* myParent = PT->getParent();
        return findfunc(myParent);
    }
}

bool anonAnalyser(ParseTreeNode* varNode) { //if the immediate preceeding node is a print or some kind of return, then we know it's anonymous
    ParseTreeNode* myParent = varNode->getParent();
    if(myParent->name == "PrintS" || myParent->name == "PrintI" || myParent->name == "PrintD"){ return true; }
    if(myParent->name == "Once_Return_Item" || myParent->name == "Inside_Return_Item"){ return true; }
    if(myParent->name == "Inner_Function_Paramters"){ return true; } //for strings specifically that aren't declared explicitly
    return false;
}

vector<ParseTreeNode*> varSearch(ParseTreeNode* root, stringstream& intermediate) { //level order tree traversal, from google with modification.

    vector<ParseTreeNode*> ivars;
    std::queue<ParseTreeNode*> q;
    q.push(root);
    string funcname; //the owner node of this variable
    while (!q.empty()) {
        ParseTreeNode* current = q.front();
        q.pop();


        //we do this to get around the intermediate rules

        if (!current->isVariable()) { //if it's not a variable, continue.
            vector<ParseTreeNode*> these = current->getChildren();
            for (int i = 0; i < these.size(); ++i) {
                q.push(these[i]);
            }
        } else { //this IS a variable
            funcname = findfunc(current); //function it belongs to
            ivars.push_back(current);
            intermediate << current->dtype << " contents: " << current->data << endl; //part of debug output

        }
    }
    return ivars;
}

//construct variable table
vector<varContainer> varTableGen (ParseTreeNode* PT, bool dflag = false) //pt is whole tree
{
    vector<varContainer> VT;
    stringstream itable;
    vector<ParseTreeNode*> filtered = varSearch(PT, itable); //fills itable
    for (int i = 0; i < filtered.size(); ++i) { //build varcontainer table
        varContainer n = *filtered[i];
        VT.push_back(n);
    }
    for (int i = 0; i < VT.size(); ++i) { //fill out details
        VT[i].setAnonymous(anonAnalyser(VT[i].getVarTree())); //now classify whether they are anonymous. basically they don't have an id attached, returns and prints. consts.
        VT[i].setOwner(findfunc(VT[i].getVarTree())); //now assign it to the functions it belongs to

    }
    if (dflag) {
       string whole;
       int vl = 0;
        while (std::getline(itable, whole)) {
            cout << whole << " " << VT[vl].isAnonymous() << " " << VT[vl].ownsThis() << endl;
            vl++;
        }
    }
    return VT;
}




//math macros - Jeremy
bool is_number(const std::string& s)
{
    std::string::const_iterator it = s.begin();
    while (it != s.end() && (std::isdigit(*it) || s[*it] == '.' || s[*it] == 'd')) ++it;
    return !s.empty() && it == s.end();
}

int mathISolver(ParseTreeNode &PT, vector<varContainer> NT){
    vector<ParseTreeNode*> children = PT.getChildren();
    int size = children.size();
    if(size == 0 && !is_number(PT.data)){
        int var = vectorNameFinder(NT, PT.data);
        MyFile << "    R[2] = Mem[SR+" << var << "]" << ";\n";
        MyFile << "    F24_Time += (20+1);\n";
        return stoi(NT[vectorNameFinder(NT, PT.data)].getData());
        }
    else if(size == 0){return stoi(PT.data);}
    else if(size == 1){return mathISolver(*children[0], NT);}
    else if(size == 1 && PT.name == "MathI3_Function_Call"){/*something that figures out function return value*/}
    else if(size == 2){
        int var1 = mathISolver(*children[0], NT);
        int var2 = mathISolver(*children[1], NT);
        if(PT.data == "+"){
            MyFile << "    R[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[1] += R[2];\n";
            MyFile << "    F24_Time += (2);\n";
            return var1 + var2;
            }
        else if(PT.data == "-"){
            MyFile << "    R[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[1] -= R[2];\n";
            MyFile << "    F24_Time += (2);\n";
            return var1 - var2;
            }
        else if(PT.data == "*"){
            MyFile << "    R[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[1] *= R[2];\n";
            MyFile << "    F24_Time += (2);\n";
            return var1 * var2;
            }
        else if(PT.data == "/"){
            MyFile << "    R[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[1] /= R[2];\n";
            MyFile << "    F24_Time += (2);\n";
            return var1 / var2;
            }
        else if(PT.data == "%"){
            MyFile << "    R[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (1);\n";
            MyFile << "    R[1] %= R[2];\n";
            MyFile << "    F24_Time += (2);\n";
            return var1 % var2;
            }
    }
    return -1;
}

double mathDSolver(ParseTreeNode &PT, vector<varContainer> NT){
    vector<ParseTreeNode*> children = PT.getChildren();
    int size = children.size();
    if(size == 0 && !is_number(PT.data)){
        int var = vectorNameFinder(NT, PT.data);
        MyFile << "    F[2] = FMem[FR+" << var << "]" << ";\n";
        MyFile << "    F24_Time += (20+2);\n";
        return stoi(NT[vectorNameFinder(NT, PT.data)].getData());
        }
    else if(size == 0){return stod(PT.data);}
    else if(size == 1){return mathDSolver(*children[0], NT);}
    else if(size == 1 && PT.name == "MathI3_Function_Call"){/*something that figures out function return value*/}
    else if(size == 2){
        double var1 = mathDSolver(*children[0], NT);
        double var2 = mathDSolver(*children[1], NT);
        if(PT.data == "+"){
            MyFile << "    F[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[1] += F[2];\n";
            MyFile << "    F24_Time += (4);\n";
            return var1 + var2;
            }
        else if(PT.data == "-"){
            MyFile << "    F[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[1] -= F[2];\n";
            MyFile << "    F24_Time += (4);\n";
            return var1 - var2;
            }
        else if(PT.data == "*"){
            MyFile << "    F[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[1] *= F[2];\n";
            MyFile << "    F24_Time += (4);\n";
            return var1 * var2;
            }
        else if(PT.data == "/"){
            MyFile << "    F[1] = " << var1 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[2] = " << var2 << ";\n";
            MyFile << "    F24_Time += (2);\n";
            MyFile << "    F[1] /= F[2];\n";
            MyFile << "    F24_Time += (4);\n";
            return var1 / var2;
            }
    }
    return -1;
}

bool equalitySolver(ParseTreeNode &PT, vector<varContainer> NT){
    vector<ParseTreeNode*> children = PT.getChildren();
    int size = children.size();
    if(size == 3){
        if(true/*dealing with int math*/){
            int var1 = mathISolver(*children[0], NT);
            int var2 = mathISolver(*children[2], NT);
            if(children[1]->data == "=="){return var1 == var2;}
            else if(children[1]->data == ">="){return var1 >= var2;}
            else if(children[1]->data == "<="){return var1 <= var2;}
            else if(children[1]->data == "<"){return var1 < var2;}
            else if(children[1]->data == ">"){return var1 > var2;}
            else if(children[1]->data == "!="){return var1 != var2;}
        }
        else{
            double var1 = mathDSolver(*children[0], NT);
            double var2 = mathDSolver(*children[2], NT);
            if(children[1]->data == "=="){return var1 == var2;}
            else if(children[1]->data == ">="){return var1 >= var2;}
            else if(children[1]->data == "<="){return var1 <= var2;}
            else if(children[1]->data == "<"){return var1 < var2;}
            else if(children[1]->data == ">"){return var1 > var2;}
            else if(children[1]->data == "!="){return var1 != var2;}
        }
    }
    else if(size == 4 && PT.data == "||"){
        if(equalitySolver(*children[0], NT)){return true;}
        if(true/*dealing with int math*/){
            int var1 = mathISolver(*children[0], NT);
            int var2 = mathISolver(*children[2], NT);
            if(children[1]->data == "=="){return var1 == var2;}
            else if(children[1]->data == ">="){return var1 >= var2;}
            else if(children[1]->data == "<="){return var1 <= var2;}
            else if(children[1]->data == "<"){return var1 < var2;}
            else if(children[1]->data == ">"){return var1 > var2;}
            else if(children[1]->data == "!="){return var1 != var2;}
        }
        else{
            double var1 = mathDSolver(*children[0], NT);
            double var2 = mathDSolver(*children[2], NT);
            if(children[1]->data == "=="){return var1 == var2;}
            else if(children[1]->data == ">="){return var1 >= var2;}
            else if(children[1]->data == "<="){return var1 <= var2;}
            else if(children[1]->data == "<"){return var1 < var2;}
            else if(children[1]->data == ">"){return var1 > var2;}
            else if(children[1]->data == "!="){return var1 != var2;}
        }
    }
    else if(size == 4 && PT.data == "&&"){
        if(!equalitySolver(*children[0], NT)){return false;}
        if(true/*dealing with int math*/){
            int var1 = mathISolver(*children[0], NT);
            int var2 = mathISolver(*children[2], NT);
            if(children[1]->data == "=="){return var1 == var2;}
            else if(children[1]->data == ">="){return var1 >= var2;}
            else if(children[1]->data == "<="){return var1 <= var2;}
            else if(children[1]->data == "<"){return var1 < var2;}
            else if(children[1]->data == ">"){return var1 > var2;}
            else if(children[1]->data == "!="){return var1 != var2;}
        }
        else{
            double var1 = mathDSolver(*children[0], NT);
            double var2 = mathDSolver(*children[2], NT);
            if(children[1]->data == "=="){return var1 == var2;}
            else if(children[1]->data == ">="){return var1 >= var2;}
            else if(children[1]->data == "<="){return var1 <= var2;}
            else if(children[1]->data == "<"){return var1 < var2;}
            else if(children[1]->data == ">"){return var1 > var2;}
            else if(children[1]->data == "!="){return var1 != var2;}
        }
    }
    else if(size == 1){return !equalitySolver(*children[0], NT);}
    return false;
}
