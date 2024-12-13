%{
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
enum ParseTreeNodeTypes {PROGRAM, FUNCTION, TYPE, INSIDE, SETEQUALTO, PRINT, ITEM};


extern int yylex();
extern int yyparse();
extern FILE* yyin;

using std::endl;
using std::cout;
void yyerror(const char *s) {
   fprintf (stderr, "%s", s);
}

%}

%union {
    int intValue;
    char* strValue;
}

%type <strValue> Program Function Type Inside SetEqualTo Print Item IDENTIFIER ICONSTANT SCONSTANT DCONSTANT

%token K_DO
%token K_DOUBLE
%token K_ELSE
%token K_EXIT//not using thus far
%token K_FUNCTION
%token K_IF
%token K_INTEGER
%token K_PRINT_DOUBLE
%token K_PRINT_INTEGER
%token K_PRINT_STRING
%token K_PROCEDURE
%token K_PROGRAM
%token K_READ_DOUBLE
%token K_READ_INTEGER
%token K_READ_STRING
%token K_RETURN
%token K_STRING
%token K_THEN
%token K_UNTIL
%token K_WHILE
%token ASSIGN
%token ASSIGN_PLUS
%token ASSIGN_MINUS
%token ASSIGN_MULTIPLY
%token ASSIGN_DIVIDE
%token ASSIGN_MOD
//%token COMMENT
%token DAND
%token DOR
%token DEQ
%token GEQ
%token LEQ
%token LE
%token DECREMENT
%token NE
%token INCREMENT
%token COMMA
%token DIVIDE
%token GT
%token LBRACKET
%token LCURLY
%token LPAREN
%token LT
%token MINUS
%token MOD
%token MULTIPLY
%token NOT
%token PERIOD//not using thus far
%token PLUS
%token RBRACKET
%token RCURLY
%token RPAREN
%token SEMI
%token IDENTIFIER
%token SCONSTANT
%token ICONSTANT
%token DCONSTANT
%left PLUS MINUS MULTIPLY

%start Program

%%
// Grammar rules with correct types usage

Program:
    K_PROGRAM IDENTIFIER LCURLY Function RCURLY {
        cout << "Program " << $2 << endl; // $2 is the IDENTIFIER

    };

Function:
    K_FUNCTION Type IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Function{
        cout << "Function " << $3 << endl; // $3 is the IDENTIFIER
    }
    | K_PROCEDURE IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Function{
        cout << "Procedure " << $2 << endl; // $2 is the IDENTIFIER
    }
    | /* empty */ {
        cout << "Function_Empty\n"; // No valid $1 reference here
    };

Type:
    K_INTEGER { cout << "K_INTEGER\n"; }
    | K_DOUBLE { cout << "K_DOUBLE\n"; }
    | K_STRING { cout << "K_STRING\n"; }
    ;
Parameters:
    Type IDENTIFIER ParametersS{
        cout << "Parameters " << $2 << endl; // $1 is the IDENTIFIER
    }
    | Type IDENTIFIER LBRACKET Math RBRACKET ParametersS{
        cout << "Parameters_Array " << $2 << endl; // $1 is the IDENTIFIER
    }
    | Type IDENTIFIER COMMA Parameters{
        cout << "Parameters_More " << $2 << endl; // $1 is the IDENTIFIER
    }
    | Type IDENTIFIER LBRACKET Math RBRACKET COMMA Parameters{
        cout << "Parameters_More_Array " << $2 << endl; // $1 is the IDENTIFIER
    }
    | ParametersS;
ParametersS:
    /* empty */ {
        cout << "Parameters_Empty\n"; // No valid $1 reference here
    };

Inside:
    Declare SEMI Inside {
        cout << "Inside_Declare\n"; // $2 is the IDENTIFIER
    }
    | SetEqualTo SEMI Inside {
        cout << "Inside_Assign\n"; // This has to be updated based on actual items
    }
    | Print SEMI Inside {
        cout << "Inside_Print\n"; // Print has no applicable items
    }
    | Read SEMI Inside {
        cout << "Inside_Read\n"; // Print has no applicable items
    }
    | IDENTIFIER LPAREN Info RPAREN SEMI Inside{
        cout << "Inside_Function_Call " << $1 << endl; // function calls made inside other functions
    }
    | K_IF LPAREN Conditional RPAREN K_THEN InsideIf Inside{
        cout << "Inside_If\n"; // function calls made inside other functions
    }
    | K_DO Till LPAREN LoopParam RPAREN InsideDo Inside{
        cout << "Inside_Do\n"; // function calls made inside other functions
    }
    | IDENTIFIER INCREMENT SEMI Inside{
        cout << "Inside_Increment_item " << $1 << endl;
    }
    | IDENTIFIER DECREMENT SEMI Inside{
        cout << "Inside_Decrement_item " << $1 << endl; // No valid $1 reference here
    }
    | K_FUNCTION Type IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Inside{
        cout << "Inside_Function_Declare " << $3 << endl; // $3 is the IDENTIFIER
    }
    | K_PROCEDURE IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Inside{
        cout << "Inside_Procedure_Declare " << $2 << endl; // $2 is the IDENTIFIER
    }
    | K_RETURN Item SEMI{
        cout << "Inside_Return_Item\n"; // No valid $1 reference here
    }
    | /* empty */ {
       cout << "Inside_Empty\n"; // No valid $1 reference here
    };
Declare:
    Type SetEqualTo{
        cout << "Declare_One\n";
    }
    | Type SetEqualTo COMMA Declare1{
        cout << "Declare_Type_More\n";
    }
    | Type IDENTIFIER {
        cout << "Declare_One_U " << $2 << endl;
    }
    | Type IDENTIFIER COMMA Declare1 {
        cout << "Declare_Type_More_U " << $2 << endl;
    };

Declare1:
    SetEqualTo{
        cout << "Declare_Done\n";
    }
    | IDENTIFIER {
       cout << "Declare_Done_U " << $1 << endl;
    }
    | SetEqualTo COMMA Declare1{
        cout << "Declare_More\n";
    }
    | IDENTIFIER COMMA Declare1{
       cout << "Declare_More_U " << $1 << endl;
    };

InsideDo:
    LCURLY Inside RCURLY{
        cout << "Do_More\n";
    }
    | Once{
        cout << "Do_Once\n";
    };

LoopParam:
    IDENTIFIER ASSIGN MathI SEMI Conditional SEMI IDENTIFIER DECREMENT{
        cout << "LoopParam " << $1 << "--\n";
    }
    | IDENTIFIER ASSIGN MathI SEMI Conditional SEMI IDENTIFIER INCREMENT{
        cout << "LoopParam " << $1 << "++\n";
    }
    | Conditional{
        cout << "LoopParam_Conditional\n";
    };

Till:
    K_WHILE{
        cout << "Do_While\n";
    }
    | K_UNTIL{
        cout << "Do_Until\n";
    }
    | /*empty*/ {
        cout << "Do_For\n";
    };

InsideIf:
    LCURLY Inside RCURLY K_ELSE{
        cout << "If_More_Else\n";
    }
    | LCURLY Inside RCURLY K_ELSE LCURLY Inside RCURLY{
        cout << "If_More_Else_More\n";
    }
    | LCURLY Inside RCURLY{
        cout << "If_More\n";
    }
    | Once K_ELSE LCURLY Inside RCURLY{
        cout << "If_Once_Else_More\n";
    }
    | Once K_ELSE{
        cout << "If_Once_Else\n";
    }
    | Once{
        cout << "If_Once\n";
    };
Once:
    Declare SEMI {
        cout << "Once_Inside_Declare\n"; // $2 is the IDENTIFIER
    }
    | SetEqualTo SEMI {
        cout << "Once_Inside_Assign " << $1 << endl; // This has to be updated based on actual items
    }
    | Print SEMI {
        cout << "Once_Inside_Print\n"; // Print has no applicable items
    }
    | Read SEMI {
        cout << "Once_Inside_Read\n"; // Print has no applicable items
    }
    | IDENTIFIER LPAREN Info RPAREN SEMI {
        cout << "Once_Inside_Function_Call " << $1 << endl; // function calls made inside other functions
    }
    | K_DO Till LPAREN LoopParam RPAREN InsideDo {
        cout << "Once_Inside_Do\n"; // function calls made inside other functions
    }
    | IDENTIFIER INCREMENT SEMI {
        cout << "Once_Increment_item " << $1 << endl; // Identifier stored in data
    }
    | IDENTIFIER DECREMENT SEMI {
        cout << "Once_Decrement_item " << $1 << endl; // Identifier stored in data
    }
    | K_RETURN Item SEMI{
        cout << "Once_Return_Item\n"; // No valid $1 reference here
    };

Conditional:
    Item ConditionalEquation Item{
        cout << "Condition_Only\n";
    }
    | NOT LPAREN Conditional RPAREN{
        cout << "Condition_Not !\n";
    }
    | Conditional DOR Item ConditionalEquation Item{
        cout << "Condition_Or ||\n";
    }
    | Conditional DAND Item ConditionalEquation Item{
        cout << "Condition_And &&\n";
    };

ConditionalEquation:
    DEQ{
        cout << "CondEq ==\n";
    }
    | GEQ{
        cout << "CondEq >=\n";
    }
    | LEQ{
        cout << "CondEq <=\n";
    }
    | NE{
        cout << "CondEq !=\n";
    }
    | GT{
        cout << "CondEq >\n";
    }
    | LT{
        cout << "CondEq <\n";
    };


Info:
    Item COMMA Info {
        cout << "Inner_Function_Parameters\n";
    }
    | Item {
        cout << "Inner_Function_Parameter\n";
    };

SetEqualTo:
    IDENTIFIER ASSIGN Item {
        cout << "Assign_Item " <<  $1 << endl; // $1 is the IDENTIFIER
    }
    | IDENTIFIER ASSIGN_DIVIDE Item {
        cout << "Assign_Item_Divide " << $1 << endl;
    }
    | IDENTIFIER ASSIGN_MINUS Item {
        cout << "Assign_Item_Minus " << $1 << endl;
    }
    | IDENTIFIER ASSIGN_MOD Item {
        cout << "Assign_Item_Mod " << $1 << endl;
    }
    | IDENTIFIER ASSIGN_MULTIPLY Item {
        cout << "Assign_Item_Multiply " << $1 << endl;
    }
    | IDENTIFIER ASSIGN_PLUS Item {
        cout << "Assign_Item_Plus " << $1 << endl;
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN Item {
        cout << "Assign_Array " << $1 << endl; // $1 is the IDENTIFIER
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_DIVIDE Item {
        cout << "Assign_Array_Divide " << $1 << endl;
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MINUS Item {
        cout << "Assign_Array_Minus " << $1 << endl;
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MOD Item {
        cout << "Assign_Array_Mod " << $1 << endl;
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MULTIPLY Item {
        cout << "Assign_Array_Multiply %s" << $1 << endl;
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_PLUS Item {
        cout << "Assign_Array_Plus " << $1 << endl;
    }
    | IDENTIFIER LBRACKET Math RBRACKET {
        cout << "Assign_Identifier_Array " << $1 << endl;
    }
    | /* empty */ {
        cout <<"Assign_Empty\n";
    };

Print:
    K_PRINT_INTEGER LPAREN Item RPAREN {
        cout << "PrintI " << $3 << endl; // $3 is the IDENTIFIER
    }
    | K_PRINT_STRING LPAREN Item RPAREN {
        cout << "PrintS " << $3 << endl;
    }
    | K_PRINT_DOUBLE LPAREN Item RPAREN {
        cout << "PrintD " << $3 << endl;
    };
Read:
    K_READ_INTEGER LPAREN IDENTIFIER RPAREN {
        cout << "ReadI " << $3 << endl; // $3 is the IDENTIFIER
    }
    | K_READ_STRING LPAREN IDENTIFIER RPAREN {
        cout << "ReadS " << $3 << endl;
    }
    | K_READ_DOUBLE LPAREN IDENTIFIER RPAREN {
        cout << "ReadD " << $3 << endl;
    }
    | K_READ_INTEGER LPAREN ICONSTANT RPAREN {
        cout << "ReadI " << $3 << endl; // $3 is ICONSTANT
    }
    | K_READ_STRING LPAREN SCONSTANT RPAREN {
        cout << "ReadS " << $3 << endl; // $3 is SCONSTANT
    }
    | K_READ_DOUBLE LPAREN DCONSTANT RPAREN {
        cout << "ReadD " << $3 << endl; // $3 is DCONSTANT
    };

Item:
    SCONSTANT {
        cout << "Item_Sconstant " << $1 << endl; // $1 is SCONSTANT
    }
    | IDENTIFIER ASSIGN Item {
        cout << "Item_Assign " << $1 << endl; // $1 is the IDENTIFIER
    }
    | IDENTIFIER LBRACKET MathI RBRACKET ASSIGN Item {
        cout << "Item_Assign_Array " << $1 << endl; // $1 is the IDENTIFIER
    }
    | MathI{
        cout << "Item_Math_Equation\n";
    };

Math:
    MathI{
        cout << "Math_Equation\n";
    }
    | /* empty */{
        cout << "Math_Empty\n";
    };
MathI:
    MathI PLUS MathI2{
        cout << "MathI_Plus +\n";
    }
    | MathI MINUS MathI2{
        cout << "MathI_Minus -\n";
    }
    | MathI2{
        cout << "MathI_to_I2\n";
    };
MathI2:
    MathI2 MULTIPLY MathI3{
        cout << "MathI2_Multiply *\n";
    }
    | MathI2 MOD MathI3{
        cout << "MathI2_Mod mod\n";
    }
    | MathI2 DIVIDE MathI3{
        cout << "MathI2_Divide /\n";
    }
    | MathI3{
        cout << "MathI2_to_I3\n";
    };
MathI3:
    IDENTIFIER{
        cout << "MathI3_Identifier " << $1 << endl;
    }
    | ICONSTANT{
        cout << "MathI3_Iconstant " << $1 << endl;
    }
    | DCONSTANT{
        cout << "MathI3_Dconstant " << $1 << endl;
    }
    | IDENTIFIER INCREMENT{
        cout << "MathI3_Identifier_Increment " << $1 << "++\n";
    }
    | IDENTIFIER DECREMENT{
        cout << "MathI3_Identifier_Decrement " << $1 << "--\n";
    }
    | LPAREN MathI RPAREN{
        cout << "MathI3_Paren_Math\n";
    }
    | MINUS IDENTIFIER{
        cout << "MathI3_Negative_Identifier -" << $2 << endl;
    }
    | MINUS ICONSTANT{
        cout << "MathI3_Negative_Iconstant -" << $2 << endl;
    }
    | MINUS DCONSTANT{
        cout << "MathI3_Negative_Dconstant -" << $2 << endl;
    }
    | MINUS IDENTIFIER LBRACKET MathI RBRACKET{
        cout << "MathI3_Negative_Array -" << $2 << endl;
    }
    | IDENTIFIER LBRACKET MathI RBRACKET{
        cout << "MathI3_Array " << $1 << endl;
    }
    | IDENTIFIER LPAREN Info RPAREN{
        cout << "MathI3_Function_Call " << $1 << endl;
    };

%%
// Main function not needed

