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
        printf("Parsed ______\n"); // Ensure $4 is valid
    }
;


Function:
    K_FUNCTION Type IDENTIFIER LPAREN RPAREN LCURLY Inside RCURLY {printf("Parsed ______\n");};

Type:
    K_INTEGER {printf("Parsed ______\n");}
    | K_DOUBLE {printf("Parsed ______\n");}
    | K_STRING {printf("Parsed ______\n");};
Inside:
    Type IDENTIFIER SEMI Inside {printf("Parsed ______\n");}
    | SetEqualTo SEMI Inside {printf("Parsed ______\n");}
    | Print SEMI Inside {printf("Parsed ______\n");}
    | /* empty */ {printf("Parsed Inside (Empty)"};
SetEqualTo:
    IDENTIFIER ASSIGN Item {printf("Parsed ______\n");}
    | IDENTIFIER ASSIGN_DIVIDE Item {printf("Parsed ______\n");}
    | IDENTIFIER ASSIGN_MINUS Item {printf("Parsed ______\n");}
    | IDENTIFIER ASSIGN_MOD Item {printf("Parsed ______\n");}
    | IDENTIFIER ASSIGN_MULTIPLY Item {printf("Parsed ______\n");}
    | IDENTIFIER ASSIGN_PLUS Item {printf("Parsed ______\n");};
Print:
    K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN {printf("Parsed ______\n");}
    | K_PRINT_STRING LPAREN IDENTIFIER RPAREN {printf("Parsed ______\n");}
    | K_PRINT_DOUBLE LPAREN IDENTIFIER RPAREN {printf("Parsed ______\n");}
    | K_PRINT_INTEGER LPAREN ICONSTANT RPAREN {printf("Parsed ______\n");}
    | K_PRINT_STRING LPAREN SCONSTANT RPAREN {printf("Parsed ______\n");}
    | K_PRINT_DOUBLE LPAREN DCONSTANT RPAREN {printf("Parsed ______\n");};
Item:
    IDENTIFIER {printf("Parsed ______\n");}
    | ICONSTANT {printf("Parsed ______\n");}
    | SCONSTANT {printf("Parsed ______\n");}
    | DCONSTANT {printf("Parsed ______\n");};


%%
int main(){
    printf("before\n");
    yyparse();
    printf("after\n");
    return 0;
}
