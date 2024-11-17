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
        printf("Increment_item\n"); // No valid $1 reference here
    }
    | IDENTIFIER DECREMENT SEMI Inside{
        printf("Decrement_item\n"); // No valid $1 reference here
    }
    | K_FUNCTION Type IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Inside{
        printf("Function \n"); // $3 is the IDENTIFIER
    }
    | K_PROCEDURE IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Inside{
        printf("Procedure %s\n", $2); // $2 is the IDENTIFIER
    }
    | K_RETURN Item SEMI{
        printf("Return_Item\n"); // No valid $1 reference here
    }
    | /* empty */ {
        printf("Inside_Empty\n"); // No valid $1 reference here
    };
Declare:
    Type SetEqualTo
    | Type SetEqualTo COMMA Declare1;
Declare1:
    SetEqualTo
    | SetEqualTo COMMA Declare1;

InsideDo:
    LCURLY Inside RCURLY
    | Once ;

LoopParam:
    IDENTIFIER ASSIGN MathI SEMI Conditional SEMI IDENTIFIER DECREMENT{}
    | IDENTIFIER ASSIGN MathI SEMI Conditional SEMI IDENTIFIER INCREMENT{}
    | Conditional{};

Till:
    K_WHILE{}
    | K_UNTIL{}
    | /*empty*/ {};

InsideIf:
    LCURLY Inside RCURLY K_ELSE
    | LCURLY Inside RCURLY K_ELSE LCURLY Inside RCURLY
    | LCURLY Inside RCURLY
    | Once K_ELSE LCURLY Inside RCURLY
    | Once K_ELSE
    | Once;
Once:
    Declare SEMI {
        printf("Inside_Declare \n"); // $2 is the IDENTIFIER
    }
    | SetEqualTo SEMI {
        printf("Inside_Assign %s\n", $1); // This has to be updated based on actual items
    }
    | Print SEMI {
        printf("Inside_Print\n"); // Print has no applicable items
    }
    | Read SEMI {
        printf("Inside_Read\n"); // Print has no applicable items
    }
    | IDENTIFIER LPAREN Info RPAREN SEMI {
        printf("Inside_Function_Call %s\n", $1); // function calls made inside other functions
    }
    | K_DO Till LPAREN LoopParam RPAREN InsideDo {
        printf("Inside_Do \n"); // function calls made inside other functions
    }
    | IDENTIFIER INCREMENT SEMI {
        printf("Increment_item\n"); // No valid $1 reference here
    }
    | IDENTIFIER DECREMENT SEMI {
        printf("Decrement_item\n"); // No valid $1 reference here
    }
    | K_RETURN Item SEMI{
        printf("Return_Item\n"); // No valid $1 reference here
    };

Conditional:
    Item ConditionalEquation Item{}
    | NOT LPAREN Conditional RPAREN{}
    | Conditional DOR Item ConditionalEquation Item{}
    | Conditional DAND Item ConditionalEquation Item{};

ConditionalEquation:
    DEQ
    | GEQ
    | LEQ
    | NE
    | GT
    | LT;


Info:
    Info1 COMMA Info {
        printf("Inside_Function_Parameters");
    }
    | IDENTIFIER COMMA Info {
        printf("Inside_Function_Parameters %s\n", $1);
    }
    | Info1 {
        printf("Inside_Function_Parameters");
    }
    | IDENTIFIER {
        printf("Inside_Function_Parameters %s\n", $1);
    };
Info1:
    SCONSTANT
    | ICONSTANT
    | DCONSTANT;

SetEqualTo:
    IDENTIFIER ASSIGN Item {
        printf("Assign %s\n", $1); // $1 is the IDENTIFIER
    }
    | IDENTIFIER ASSIGN_DIVIDE Item {
        printf("Assign_Divide %s\n", $1);
    }
    | IDENTIFIER ASSIGN_MINUS Item {
        printf("Assign_Minus %s\n", $1);
    }
    | IDENTIFIER ASSIGN_MOD Item {
        printf("Assign_Mod %s\n", $1);
    }
    | IDENTIFIER ASSIGN_MULTIPLY Item {
        printf("Assign_Multiply %s\n", $1);
    }
    | IDENTIFIER ASSIGN_PLUS Item {
        printf("Assign_Plus %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN Item {
        printf("Assign %s\n", $1); // $1 is the IDENTIFIER
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_DIVIDE Item {
        printf("Assign_Divide %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MINUS Item {
        printf("Assign_Minus %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MOD Item {
        printf("Assign_Mod %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_MULTIPLY Item {
        printf("Assign_Multiply %s\n", $1);
    }
    | IDENTIFIER LBRACKET Math RBRACKET ASSIGN_PLUS Item {
        printf("Assign_Plus %s\n", $1);
    }
    | IDENTIFIER {}
    | IDENTIFIER LBRACKET Math RBRACKET {}
    | /* empty */ {};

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
        printf("PrintI %s\n", $3); // $3 is the IDENTIFIER
    }
    | K_READ_STRING LPAREN IDENTIFIER RPAREN {
        printf("PrintS %s\n", $3);
    }
    | K_READ_DOUBLE LPAREN IDENTIFIER RPAREN {
        printf("PrintD %s\n", $3);
    }
    | K_READ_INTEGER LPAREN ICONSTANT RPAREN {
        printf("PrintI %s\n", $3); // $3 is ICONSTANT
    }
    | K_READ_STRING LPAREN SCONSTANT RPAREN {
        printf("PrintS %s\n", $3); // $3 is SCONSTANT
    }
    | K_READ_DOUBLE LPAREN DCONSTANT RPAREN {
        printf("PrintD %s\n", $3); // $3 is DCONSTANT
    };

Item:
    SCONSTANT {
        printf("Sconstant %s\n", $1); // $1 is SCONSTANT
    }
    | IDENTIFIER ASSIGN Item
    | IDENTIFIER LBRACKET MathI RBRACKET ASSIGN Item
    | MathI {};

Math:
    MathI
    | /* empty */;
MathI:
    MathI PLUS MathI2
    | MathI MINUS MathI2
    | MathI2;
MathI2:
    MathI2 MULTIPLY MathI3
    | MathI2 MOD MathI3
    | MathI2 DIVIDE MathI3
    | MathI3;
MathI3:
    IDENTIFIER{}
    | ICONSTANT{}
    | DCONSTANT{}
    | IDENTIFIER INCREMENT
    | IDENTIFIER DECREMENT
    | LPAREN MathI RPAREN
    | MINUS IDENTIFIER
    | MINUS ICONSTANT
    | MINUS DCONSTANT
    | MINUS IDENTIFIER LBRACKET MathI RBRACKET
    | IDENTIFIER LBRACKET MathI RBRACKET{}
    | IDENTIFIER LPAREN Info RPAREN{};

%%
// Main function

int main(){
    yyparse();
    return 0;
}
