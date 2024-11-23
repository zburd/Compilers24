%{
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
enum ParseTreeNodeTypes {PROGRAM, FUNCTION, TYPE, INSIDE, SETEQUALTO, PRINT, ITEM};

extern int yylex();
extern int yyparse();
extern FILE* yyin;
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
        printf("Program %s\n", $2); // $2 is the IDENTIFIER
    }
;

Function:
    K_FUNCTION Type IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Function{
        printf("Function %s\n", $3); // $3 is the IDENTIFIER
    }
    | K_PROCEDURE IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Function{
        printf("Procedure %s\n", $2); // $2 is the IDENTIFIER
    }
    | /* empty */ {
        printf("Function_Empty\n"); // No valid $1 reference here
    };

Type:
    K_INTEGER { printf("K_INTEGER\n"); }
    | K_DOUBLE { printf("K_DOUBLE\n"); }
    | K_STRING { printf("K_STRING\n"); };

Parameters:
    Type IDENTIFIER ParametersS{
        printf("Parameters %s\n", $2); // $1 is the IDENTIFIER
    }
    | Type IDENTIFIER LBRACKET Math RBRACKET ParametersS{
        printf("Parameters %s\n", $2); // $1 is the IDENTIFIER
    }
    | Type IDENTIFIER COMMA Parameters{
        printf("Parameters %s\n", $2); // $1 is the IDENTIFIER
    }
    | Type IDENTIFIER LBRACKET Math RBRACKET COMMA Parameters{
        printf("Parameters %s\n", $2); // $1 is the IDENTIFIER
    }
    | ParametersS;
ParametersS:
    /* empty */ {
        printf("Parameters_Empty\n"); // No valid $1 reference here
    }

Inside:
    Declare SEMI Inside {
        printf("Inside_Declare \n"); // $2 is the IDENTIFIER
    }
    | SetEqualTo SEMI Inside {
        printf("Inside_Assign %s\n", $1); // This has to be updated based on actual items
    }
    | Print SEMI Inside {
        printf("Inside_Print\n"); // Print has no applicable items
    }
    | Read SEMI Inside {
        printf("Inside_Read\n"); // Print has no applicable items
    }
    | IDENTIFIER LPAREN Info RPAREN SEMI Inside{
        printf("Inside_Function_Call %s\n", $1); // function calls made inside other functions
    }
    | K_IF LPAREN Conditional RPAREN K_THEN InsideIf Inside{
        printf("Inside_If \n"); // function calls made inside other functions
    }
    | K_DO Till LPAREN LoopParam RPAREN InsideDo Inside{
        printf("Inside_Do \n"); // function calls made inside other functions
    }
    | IDENTIFIER INCREMENT SEMI Inside{
        printf("Inside_Increment_item\n"); // No valid $1 reference here
    }
    | IDENTIFIER DECREMENT SEMI Inside{
        printf("Inside_Decrement_item\n"); // No valid $1 reference here
    }
    | K_FUNCTION Type IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Inside{
        printf("Inside_Function_Declare \n"); // $3 is the IDENTIFIER
    }
    | K_PROCEDURE IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Inside{
        printf("Inside_Procedure_Declare %s\n", $2); // $2 is the IDENTIFIER
    }
    | K_RETURN Item SEMI{
        printf("Inside_Return_Item\n"); // No valid $1 reference here
    }
    | /* empty */ {
        printf("Inside_Empty\n"); // No valid $1 reference here
    };
Declare:
    Type SetEqualTo{
        printf("Declare_One \n");
    }
    | Type SetEqualTo COMMA Declare1{
        printf("Declare_Type_More \n");
    };
Declare1:
    SetEqualTo{
        printf("Declare_Done \n");
    }
    | SetEqualTo COMMA Declare1{
        printf("Declare_More \n");
    };

InsideDo:
    LCURLY Inside RCURLY{
        printf("Do_More\n");
    }
    | Once{
        printf("Do_Once\n");
    };

LoopParam:
    IDENTIFIER ASSIGN MathI SEMI Conditional SEMI IDENTIFIER DECREMENT{
        printf("LoopParam %s --\n", $1);
    }
    | IDENTIFIER ASSIGN MathI SEMI Conditional SEMI IDENTIFIER INCREMENT{
        printf("LoopParam %s ++\n", $1);
    }
    | Conditional;

Till:
    K_WHILE{
        printf("While\n");
    }
    | K_UNTIL{
        printf("Until\n");
    }
    | /*empty*/ {
        printf("For\n");
    };

InsideIf:
    LCURLY Inside RCURLY K_ELSE{
        printf("If_More_Else\n");
    }
    | LCURLY Inside RCURLY K_ELSE LCURLY Inside RCURLY{
        printf("If_More_Else_More\n");
    }
    | LCURLY Inside RCURLY{
        printf("If_More\n");
    }
    | Once K_ELSE LCURLY Inside RCURLY{
        printf("If_Once_Else_More\n");
    }
    | Once K_ELSE{
        printf("If_Once_Else\n");
    }
    | Once{
        printf("If_Once\n");
    };
Once:
    Declare SEMI {
        printf("Once_Inside_Declare \n"); // $2 is the IDENTIFIER
    }
    | SetEqualTo SEMI {
        printf("Once_Inside_Assign %s\n", $1); // This has to be updated based on actual items
    }
    | Print SEMI {
        printf("Once_Inside_Print\n"); // Print has no applicable items
    }
    | Read SEMI {
        printf("Once_Inside_Read\n"); // Print has no applicable items
    }
    | IDENTIFIER LPAREN Info RPAREN SEMI {
        printf("Once_Inside_Function_Call %s\n", $1); // function calls made inside other functions
    }
    | K_DO Till LPAREN LoopParam RPAREN InsideDo {
        printf("Once_Inside_Do \n"); // function calls made inside other functions
    }
    | IDENTIFIER INCREMENT SEMI {
        printf("Once_Increment_item %s\n", $1); // Identifier stored in data
    }
    | IDENTIFIER DECREMENT SEMI {
        printf("Once_Decrement_item %s\n", $1); // Identifier stored in data 
    }
    | K_RETURN Item SEMI{
        printf("Once_Return_Item\n"); // No valid $1 reference here
    };

Conditional:
    Item ConditionalEquation Item{
        printf("Condition_Only\n");
    }
    | NOT LPAREN Conditional RPAREN{
        printf("Condition_Not !\n");
    }
    | Conditional DOR Item ConditionalEquation Item{
        printf("Condition_Or ||\n");
    }
    | Conditional DAND Item ConditionalEquation Item{
        printf("Condition_And &&\n");
    };

ConditionalEquation:
    DEQ{
        printf("CondEq ==\n");
    }
    | GEQ{
        printf("CondEq >=\n");
    }
    | LEQ{
        printf("CondEq <=\n");
    }
    | NE{
        printf("CondEq !=\n");
    }
    | GT{
        printf("CondEq >\n");
    }
    | LT{
        printf("CondEq <\n");
    };


Info:
    Item COMMA Info {
        printf("Inner_Function_Parameters\n");
    }
    | Item {
        printf("Inner_Function_Parameters\n");
    };

SetEqualTo:
    IDENTIFIER ASSIGN Item {
        printf("Assign_Item %s\n", $1); // $1 is the IDENTIFIER
    }
    | IDENTIFIER ASSIGN_DIVIDE Item {
        printf("Assign_Item_Divide %s\n", $1);
    }
    | IDENTIFIER ASSIGN_MINUS Item {
        printf("Assign_Item_Minus %s\n", $1);
    }
    | IDENTIFIER ASSIGN_MOD Item {
        printf("Assign_Item_Mod %s\n", $1);
    }
    | IDENTIFIER ASSIGN_MULTIPLY Item {
        printf("Assign_Item_Multiply %s\n", $1);
    }
    | IDENTIFIER ASSIGN_PLUS Item {
        printf("Assign_Item_Plus %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN Item {
        printf("Assign_Array %s\n", $1); // $1 is the IDENTIFIER
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_DIVIDE Item {
        printf("Assign_Array_Divide %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MINUS Item {
        printf("Assign_Array_Minus %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MOD Item {
        printf("Assign_Array_Mod %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MULTIPLY Item {
        printf("Assign_Array_Multiply %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_PLUS Item {
        printf("Assign_Array_Plus %s\n", $1);
    }
    | IDENTIFIER {
        printf("Assign_Identifier %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET {
        printf("Assign_Identifier_Array %s\n", $1);
    }
    | /* empty */ {
        printf("Assign_Empty \n");
    };

Print:
    K_PRINT_INTEGER LPAREN Item RPAREN {
        printf("PrintI %s\n", $3); // $3 is the IDENTIFIER
    }
    | K_PRINT_STRING LPAREN Item RPAREN {
        printf("PrintS %s\n", $3);
    }
    | K_PRINT_DOUBLE LPAREN Item RPAREN {
        printf("PrintD %s\n", $3);
    };
Read:
    K_READ_INTEGER LPAREN IDENTIFIER RPAREN {
        printf("ReadI %s\n", $3); // $3 is the IDENTIFIER
    }
    | K_READ_STRING LPAREN IDENTIFIER RPAREN {
        printf("ReadS %s\n", $3);
    }
    | K_READ_DOUBLE LPAREN IDENTIFIER RPAREN {
        printf("ReadD %s\n", $3);
    }
    | K_READ_INTEGER LPAREN ICONSTANT RPAREN {
        printf("ReadI %s\n", $3); // $3 is ICONSTANT
    }
    | K_READ_STRING LPAREN SCONSTANT RPAREN {
        printf("ReadS %s\n", $3); // $3 is SCONSTANT
    }
    | K_READ_DOUBLE LPAREN DCONSTANT RPAREN {
        printf("ReadD %s\n", $3); // $3 is DCONSTANT
    };

Item:
    SCONSTANT {
        printf("Item_Sconstant %s\n", $1); // $1 is SCONSTANT
    }
    | IDENTIFIER ASSIGN Item {
        printf("Item_Assign %s\n", $1); // $1 is the IDENTIFIER
    }
    | IDENTIFIER LBRACKET MathI RBRACKET ASSIGN Item {
        printf("Item_Assign_Array %s\n", $1); // $1 is the IDENTIFIER
    }
    | MathI{
        printf("Item_Math_Equation");
    };

Math:
    MathI{
        printf("Math_Equation");
    }
    | /* empty */;
MathI:
    MathI PLUS MathI2{
        printf("Plus +\n");
    }
    | MathI MINUS MathI2{
        printf("Minus -\n");
    }
    | MathI2;
MathI2:
    MathI2 MULTIPLY MathI3{
        printf("Multiply *\n");
    }
    | MathI2 MOD MathI3{
        printf("Mod \n");
    }
    | MathI2 DIVIDE MathI3{
        printf("Divide /\n");
    }
    | MathI3;
MathI3:
    IDENTIFIER{
        printf("Identifier %s\n", $1);
    }
    | ICONSTANT{
        printf("Iconstant %s\n", $1);
    }
    | DCONSTANT{
        printf("Dconstant %s\n", $1);
    }
    | IDENTIFIER INCREMENT{
        printf("Identifier_Increment %s++\n", $1);
    }
    | IDENTIFIER DECREMENT{
        printf("Identifier_Decrement %s--\n", $1);
    }
    | LPAREN MathI RPAREN
    | MINUS IDENTIFIER{
        printf("Negative_Identifier -%s\n", $2);
    }
    | MINUS ICONSTANT{
        printf("Negative_Iconstant -%s\n", $2);
    }
    | MINUS DCONSTANT{
        printf("Negative_Dconstant -%s\n", $2);
    }
    | MINUS IDENTIFIER LBRACKET MathI RBRACKET{
        printf("Negative_Array -%s\n", $2);
    }
    | IDENTIFIER LBRACKET MathI RBRACKET{
        printf("Array %s\n", $1);
    }
    | IDENTIFIER LPAREN Info RPAREN{
        printf("Function_Call %s\n", $1);
    };

%%
// Main function

int main(){
    yyparse();
    return 0;
}
