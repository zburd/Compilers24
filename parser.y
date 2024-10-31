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
    | K_PROCEDURE Type IDENTIFIER LPAREN Parameters RPAREN LCURLY Inside RCURLY Function{
        printf("Procedure %s\n", $3); // $3 is the IDENTIFIER
    }
    | /* empty */ {
        printf("Function_Empty\n"); // No valid $1 reference here
    };

Type:
    K_INTEGER { printf("K_INTEGER\n"); }
    | K_DOUBLE { printf("K_DOUBLE\n"); }
    | K_STRING { printf("K_STRING\n"); };

Parameters:
    Type IDENTIFIER{
        printf("Parameters %s\n", $2); // $3 is the IDENTIFIER
    }
    | Type IDENTIFIER COMMA Parameters{
        printf("Parameters %s\n", $3); // $3 is the IDENTIFIER
    }
    | /* empty */ {
        printf("Parameters_Empty\n"); // No valid $1 reference here
    };

Inside:
    Type IDENTIFIER SEMI Inside {
        printf("Inside_Declare %s\n", $2); // $2 is the IDENTIFIER
    }
    | SetEqualTo SEMI Inside {
        printf("Inside_Assign %s\n", $1); // This has to be updated based on actual items
    }
    | Print SEMI Inside {
        printf("Inside_Print\n"); // Print has no applicable items
    }
    | /* empty */ {
        printf("Inside_Empty\n"); // No valid $1 reference here
    };

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
    };

Print:
    K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN {
        printf("PrintI %s\n", $3); // $3 is the IDENTIFIER
    }
    | K_PRINT_STRING LPAREN IDENTIFIER RPAREN {
        printf("PrintS %s\n", $3);
    }
    | K_PRINT_DOUBLE LPAREN IDENTIFIER RPAREN {
        printf("PrintD %s\n", $3);
    }
    | K_PRINT_INTEGER LPAREN ICONSTANT RPAREN {
        printf("PrintI %s\n", $3); // $3 is ICONSTANT
    }
    | K_PRINT_STRING LPAREN SCONSTANT RPAREN {
        printf("PrintS %s\n", $3); // $3 is SCONSTANT
    }
    | K_PRINT_DOUBLE LPAREN DCONSTANT RPAREN {
        printf("PrintD %s\n", $3); // $3 is DCONSTANT
    };

Item:
    IDENTIFIER {
        printf("Identifier %s\n", $1); // $1 is the IDENTIFIER
    }
    | ICONSTANT {
        printf("Iconstant %s\n", $1); // $1 is ICONSTANT
    }
    | SCONSTANT {
        printf("Sconstant %s\n", $1); // $1 is SCONSTANT
    }
    | DCONSTANT {
        printf("Dconstant %s\n", $1); // $1 is DCONSTANT
    };

%%
// Main function

int main(){
    yyparse();
    return 0;
}
