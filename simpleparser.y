%{
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
enum ParseTreeNodeTypes {PROGRAM, FUNCTION, TYPE, INSIDE, SETEQUALTO, PRINT, ITEM};

extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char *s) {
   fprintf (stderr, "%s\n", s);
}


%}

%union {
    int intValue;
}


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
%token LEQ
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

Program:
    K_PROGRAM IDENTIFIER LCURLY Function RCURLY {
        printf("Program\n");
    }
;


Function:
    K_FUNCTION Type IDENTIFIER LPAREN RPAREN LCURLY Inside RCURLY {printf("Function\n");};

Type:
    K_INTEGER {printf("K_INTEGER\n");}
    | K_DOUBLE {printf("K_DOUBLE\n");}
    | K_STRING {printf("K_STRING\n");};
Inside:
    Type IDENTIFIER SEMI Inside {printf("Inside_Declare\n");}
    | SetEqualTo SEMI Inside {printf("Inside_Assign\n");}
    | Print SEMI Inside {printf("Inside_Print\n");}
    | /* empty */ {printf("Inside_Empty\n");};
SetEqualTo:
    IDENTIFIER ASSIGN Item {printf("Assign\n");}
    | IDENTIFIER ASSIGN_DIVIDE Item {printf("Assign_Divide\n");}
    | IDENTIFIER ASSIGN_MINUS Item {printf("Assign_Minus\n");}
    | IDENTIFIER ASSIGN_MOD Item {printf("Assign_Mod\n");}
    | IDENTIFIER ASSIGN_MULTIPLY Item {printf("Assign_Multiply\n");}
    | IDENTIFIER ASSIGN_PLUS Item {printf("Assign_Plus\n");};
Print:
    K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN {printf("PrintI\n");}
    | K_PRINT_STRING LPAREN IDENTIFIER RPAREN {printf("PrintS\n");}
    | K_PRINT_DOUBLE LPAREN IDENTIFIER RPAREN {printf("PrintD\n");}
    | K_PRINT_INTEGER LPAREN ICONSTANT RPAREN {printf("PrintI\n");}
    | K_PRINT_STRING LPAREN SCONSTANT RPAREN {printf("PrintS\n");}
    | K_PRINT_DOUBLE LPAREN DCONSTANT RPAREN {printf("PrintD\n");};
Item:
    IDENTIFIER {printf("Identifier\n");}
    | ICONSTANT {printf("Iconstant\n");}
    | SCONSTANT {printf("Sconstant\n");}
    | DCONSTANT {printf("Dconstant\n");};


%%
int main(){
    yyparse();
    return 0;
}
