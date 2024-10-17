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
        printf("Parsed Program\n"); // Ensure $4 is valid
    }
;


Function:
    K_FUNCTION Type IDENTIFIER LPAREN RPAREN LCURLY Inside RCURLY {printf("Parsed Function\n");};

Type:
    K_INTEGER {printf("Parsed K_INTEGER\n");}
    | K_DOUBLE {printf("Parsed K_DOUBLE\n");}
    | K_STRING {printf("Parsed K_STRING\n");};
Inside:
    Type IDENTIFIER SEMI Inside {printf("Parsed Inside (Declare)\n");}
    | SetEqualTo SEMI Inside {printf("Parsed Inside (Assign)\n");}
    | Print SEMI Inside {printf("Parsed Inside (Print)\n");}
    | /* empty */ {printf("Parsed Inside (Empty)\n");};
SetEqualTo:
    IDENTIFIER ASSIGN Item {printf("Parsed SetEqualTo\n");}
    | IDENTIFIER ASSIGN_DIVIDE Item {printf("Parsed SetEqualTo\n");}
    | IDENTIFIER ASSIGN_MINUS Item {printf("Parsed SetEqualTo\n");}
    | IDENTIFIER ASSIGN_MOD Item {printf("Parsed SetEqualTo\n");}
    | IDENTIFIER ASSIGN_MULTIPLY Item {printf("Parsed SetEqualTo\n");}
    | IDENTIFIER ASSIGN_PLUS Item {printf("Parsed SetEqualTo\n");};
Print:
    K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN {printf("Parsed Print I\n");}
    | K_PRINT_STRING LPAREN IDENTIFIER RPAREN {printf("Parsed Print S\n");}
    | K_PRINT_DOUBLE LPAREN IDENTIFIER RPAREN {printf("Parsed Print D\n");}
    | K_PRINT_INTEGER LPAREN ICONSTANT RPAREN {printf("Parsed Print I\n");}
    | K_PRINT_STRING LPAREN SCONSTANT RPAREN {printf("Parsed Print S\n");}
    | K_PRINT_DOUBLE LPAREN DCONSTANT RPAREN {printf("Parsed Print D\n");};
Item:
    IDENTIFIER {printf("Parsed identifier\n");}
    | ICONSTANT {printf("Parsed int constant\n");}
    | SCONSTANT {printf("Parsed string constant\n");}
    | DCONSTANT {printf("Parsed double constant\n");};


%%
int main(){
    printf("before\n");
    yyparse();
    printf("after\n");
    return 0;
}
