%{
#include <stdio.h>
#include <FlexLexer.h>
#include <vector>
#include "token.h"
#include "operation.h"
#include "keyword.h"
#include "punctuation.h"

using std::endl;
using std::cerr;
using std::cout;
using std::string;


void yyerror(char *s);
int nodenum = 1;

extern yyFlexLexer *scanner;

#define yylex() scanner->yylex()

//preliminary type checking stuff. this is dtype
    //0 = int
    //1 = double
    //2 = string

//the varContainer struct basically contains the type and value
//replace with class if this gets wonky

struct varContainer {
    int dtype;

    int ival;
    double dval;
    string sval;

};

%}

%union {
    char varname[40]; //length of 40 characters for var names, aka identifiers
    vector<varContainer> programvariables;
    //we're gonna use vectors for this, because we dont want this to be an arbitrary fixed size.
}

%token K_INTEGER K_DOUBLE K_STRING
%token K_READ_INTEGER K_READ_DOUBLE K_READ_STRING
%token K_PRINT_INTEGER K_PRINT_DOUBLE K_PRINT_STRING
%token K_PROCEDURE K_PROGRAM K_FUNCTION
%token K_DO K_WHILE K_UNTIL K_THEN
%token K_RETURN K_EXIT
%token K_IF K_ELSE

%left PLUS MINUS MULTIPLY DIVIDE MOD

%token INCREMENT DECREMENT
%token DOR DAND NOT DEQ GEQ GT LEQ LT NE

%right ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULTIPLY ASSIGN_DIVIDE ASSIGN_MOD ASSIGN

%token PERIOD SEMI LBRACKET RBRACKET LCURLY RCURLY LPAREN RPAREN COMMA

%token <varname> IDENTIFIER

%token ICONSTANT DCONSTANT SCONSTANT
%token <varname> SCONSTANT
%token <varname> DCONSTANT
%token <varname> ICONSTANT

%start program

%%
    //program contains a name and at least one function, first node
program:
    K_PROGRAM IDENTIFIER LCURLY function RCURLY
    {
        cout << "Program start.\n";
        $$ = $1;
    } 
    |
    {
        cout << "Parsing error.\n";
    }
;
//input functions
builtin_func_input:
    K_READ_INTEGER LPAREN IDENTIFIER RPAREN SEMI
    {

    }
    | K_READ_DOUBLE LPAREN IDENTIFIER RPAREN SEMI
    {

    }
    | K_READ_STRING LPAREN IDENTIFIER RPAREN SEMI
    {

    }
;
    //output functions
builtin_func_output:
    K_PRINT_INTEGER expression SEMI
    {
        $$ = $2;
    }
    | K_PRINT_DOUBLE expression SEMI
    {
        $$ = $2;
    }
    | K_PRINT_STRING expression SEMI
    {
        $$ = $2;
    }
//may not need semi at the end?
;
    //variable declaration
vardec:
    K_INTEGER IDENTIFIER SEMI
    {
        cout << "Declared integer.\n";
        $$ = $1;
    }
    | K_DOUBLE IDENTIFIER SEMI
    {
        cout << "Declared double.\n";
        $$ = $1;
    }
    | K_STRING IDENTIFIER SEMI
    {
        cout << "Declared string.\n";
        $$ = $1;
    }
;
    //function contains expressions
function:
    K_FUNCTION K_INTEGER IDENTIFIER LPAREN RPAREN LCURLY expressions RCURLY
    {
        $$ = $1;
        cout << "Integer function declared.\n";
    }
    | K_FUNCTION K_DOUBLE IDENTIFIER LPAREN RPAREN LCURLY expressions RCURLY
    {
        $$ = $1;
        cout << "Double function declared.\n";
    }
    | K_FUNCTION K_STRING IDENTIFIER LPAREN RPAREN LCURLY expressions RCURLY
    {
        $$ = $1;
        cout << "String function declared.\n";
    }
;
    //one or more expressions, we do NOT need to have any code here
expressions:
    | expression SEMI expressions
;

expression: vardec
    {
        cout << "Variable declaration.\n";
        $$ = $1;
    }
    | builtin_func_input
    {

    }
    | builtin_func_output
    {
        cout << "Printing variable.\n";
        $$ = $1;
    }
    | var_assign
    {
        cout << "Variable assignment.\n";
        $$ = $1;
    } //we will need to handle other types of assignment separately
    | LPAREN expression RPAREN //revert to old way if this causes problems.
    {
        $$ = $2;
    }
;
var_assign: //type checking of the variable being assigned to will need to happen here! In each rule too, before we do anything.
    IDENTIFIER ASSIGN consttypes
    { //normal assignment
        $$ = $3;
    }
    | IDENTIFIER ASSIGN_PLUS consttypes
    {
        //if string, should we concatenate?
        //otherwise should only work with doubles and integers
    }
    | IDENTIFIER ASSIGN_MINUS consttypes
    {
        //should only work with doubles and integers
    }
    | IDENTIFIER ASSIGN_MULTIPLY consttypes
    {
        //should only work with doubles and integers
    }
    | IDENTIFIER ASSIGN_DIVIDE consttypes
    {
        //should only work with doubles and integers
    }
    | IDENTIFIER ASSIGN_MOD consttypes
    {
        //should only work with doubles and integers
    }
;
consttypes:
    ICONSTANT
    {
        $$ = $1;
        cout << "An integer.\n";
    }
    | DCONSTANT
    {
        $$ = $1;
        cout << "A double.\n";
    }
    | SCONSTANT
    {
        $$ = $1;
        cout << "A string.\n";
    }

;


%%
void yyerror(char *s)
{
    fprintf(stderr, "%s\n", s);
}
//consider this link https://github.com/Shuvo091/simple-programming-language-using-flex-and-bison/tree/master
