%{
#include<stdio.h>
#include <stdlib.h>
%}

%token K_DO
%token K_DOUBLE
%token K_ELSE
%token K_EXIT
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
%token COMMENT
%token DAND
%token DOR
%token DEQ
%token GEQ
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
%token PERIOD
%token PLUS
%token RBRACKET
%token RCURLY
%token RPAREN
%token SEMI

%token IDENTIFIER 
%token SCONSTANT
%token ICONSTANT
%token DCONSTANT

%start Program

%%

/* TODO
//add in components for tree representation later
	{printf("++++++++++++++++++++++++++++++++++++++++++++++++\n+ Walking through the Parse Tree Begins Here\n++++++++++++++++++++++++++++++++++++++++++++++++\n");}//starter
	{printf(“**Node %i: Reduced: name: (anything that involves actions and terminals)”, node);//node information}
	{printf("****action name -> simplest form of action name (e.g. IDENTIFIER a, parse tree node) if not parse tree node then name of thing");//branch information}
	{printf("****terminal symbol terminal name");}
//get rid of this line last after double checking.
*/
Program:
    K_PROGRAM IDENTIFIER RCURLY Outside LCURLY;

Outside:
    Function Outside
    | Line SEMI Outside
    | /* empty */;


Function:
    Type IDENTIFIER LPAREN Variables RPAREN RCURLY Inside LCURLY;
/* TODO
//check if this is all a line can do
//also it gets a semicolin when called above
*/
Line:
    Define
    | SetEqualTo
    | Action;

/* TODO
//make types of the type instead of the tokens
*/
Type:
    DCONSTANT
    | ICONSTANT
    | SCONSTANT;
Variables:
    Type IDENTIFIER
    | Type IDENTIFIER COMMA Variable
    | /* empty */;
Inside:
    Line SEMI
    | Line SEMI Inside
    | /* empty */;
Define:
    Type IDENTIFIER;
/* TODO
//add in ability to have an identifier equal a function
*/
SetEqualTo:
    IDENTIFIER ASSIGN Expression;
Action:
    Keyed
    | UserMade;


Variable:
    Type IDENTIFIER
    | Type IDENTIFIER COMMA Variable;
Expression:
    String
    | Integer
    | Double;
/* TODO
//Make sure all function keys are accounted for
*/
Keyed:
    Print
    | Read
    | If
    | Else
    | Do
    | While;
UserMade:
    IDENTIFIER LPAREN Variables RPAREN;


String:
    IDENTIFIER
    | SCONSTANT;
Integer:
    Mathi;
Double:
    Mathd;
Print:
    K_PRINT_INTEGER LPAREN Integer RPAREN
    | K_PRINT_DOUBLE LPAREN Double RPAREN
    | K_PRINT_STRING LPAREN String RPAREN;
Read:
    K_READ_INTEGER LPAREN Integer RPAREN
    | K_READ_DOUBLE LPAREN Double RPAREN
    | K_READ_STRING LPAREN String RPAREN;
If:
    K_IF LPAREN Equality RPAREN LCURLY Inside RCURLY;
Else:
    K_ELSE K_IF LPAREN Equality RPAREN LCURLY Inside RCURLY
    | K_ELSE LCURLY Inside RCURLY;
/* TODO
//fix so that it can be a good for statment
*/
Do:
    K_DO K_UNTIL LPAREN Equality RPAREN LCURLY Inside RCURLY;
/* TODO
//double check to see if the while statment is correct
*/
While:
    K_DO K_WHILE LPAREN Equality RPAREN LCURLY Inside RCURLY;

/* TODO
//add in any math expresions i forgot
*/

Plusminus:
    PLUS
    | MINUS;
Mathi:
    Mathi Plusminus Termi
    | Mathi Plusminus Termi
    | Termi;
Mathd:
    Mathd Plusminus Termd
    | Mathd Plusminus Termd
    | Termd;
Equality:
    Equality DAND Statment
    | Equality DOR Statment
    | Statment;


Termi:
    Termi MULTIPLY Factori
    | Termi DIVIDE Factori
    | Factori;
Termd:
    Termd MULTIPLY Factord
    | Termd DIVIDE Factord
    | Factord;
/* TODO
//double check statments to make sure everything is set up properly
*/
Statment:
    Integer DEQ Integer
    | Double DEQ Double
    | String DEQ String
    | Integer GEQ Integer
    | Double GEQ Double
    | Integer GT Integer
    | Double GT Double
    | Integer LEQ Integer
    | Double LEQ Double
    | Integer LT Integer
    | Double LT Double
    | Integer NE Integer
    | Double NE Double
    | NOT LPAREN Equality RPAREN
    | 'True'
    | 'False';


Factori:
    IDENTIFIER
    | K_INTEGER
    | LPAREN Mathi RPAREN
    | MINUS Mathi;
Factord:
    IDENTIFIER
    | K_DOUBLE
    | LPAREN Mathd RPAREN
    | MINUS Mathd;

%%
