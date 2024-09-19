%{
#include<stdio.h>
#include <stdlib.h>
%}

K_DO               "do"
K_DOUBLE           "double"
K_ELSE             "else"
K_EXIT             "exit"
K_FUNCTION         "function"
K_IF               "if"
K_INTEGER          "integer"
K_PRINT_DOUBLE     "print_double"
K_PRINT_INTEGER    "print_integer"
K_PRINT_STRING     "print_string"
K_PROCEDURE        "procedure"
K_PROGRAM          "program"
K_READ_DOUBLE      "read_double"
K_READ_INTEGER     "read_integer"
K_READ_STRING      "read_string"
K_RETURN           "return"
K_STRING           "string"
K_THEN             "then"
K_UNTIL            "until"
K_WHILE            "while"

ASSIGN             ":="
ASSIGN_PLUS        "+="
ASSIGN_MINUS       "-="
ASSIGN_MULTIPLY    "*="
ASSIGN_DIVIDE      "/="
ASSIGN_MOD         "%="
COMMENT            [/]{2}.*
DAND               "&&"
DOR                "||"
DEQ                "=="
GEQ                ">="
LEQ                "<="
DECREMENT          "--"
NE                 "!="
INCREMENT          "++"

COMMA              ","
DIVIDE             "/"
GT                 ">"
LBRACKET           "["
LCURLY             "{"
LPAREN             "("
LT                 "<"
MINUS              "-"
MOD                "%"
MULTIPLY           "*"
NOT                "!"
PERIOD             "."
PLUS               "+"
RBRACKET           "]"
RCURLY             "}"
RPAREN             ")"
SEMI               ";"

WHITESPACE [ |\t]*

IDENTIFIER [a-zA-Z$_][a-zA-Z0-9$_]{0,31}
SCONSTANT "\""([^"\\]|\\.)*"\""
ICONSTANT [0-9]+
DCONSTANT (([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*))
%%
{K_DO} { printf("%s: K_DO \n", yytext); }
{K_DOUBLE} { printf("%s: K_DOUBLE \n", yytext); }
{K_ELSE} { printf("%s: K_ELSE \n", yytext); }
{K_EXIT} { printf("%s: K_EXIT \n", yytext); }
{K_FUNCTION} { printf("%s: K_FUNCTION \n", yytext); }
{K_IF} { printf("%s: K_IF \n", yytext); }
{K_INTEGER} { printf("%s: K_INTEGER \n", yytext); }
{K_PRINT_DOUBLE} { printf("%s: K_PRINT_DOUBLE \n", yytext); }
{K_PRINT_INTEGER} { printf("%s: K_PRINT_INTEGER \n", yytext); }
{K_PRINT_STRING} { printf("%s: K_PRINT_STRING \n", yytext); }
{K_PROCEDURE} { printf("%s: K_PROCEDURE \n", yytext); }
{K_PROGRAM} { printf("%s: K_PROGRAM \n", yytext); }
{K_READ_DOUBLE} { printf("%s: K_READ_DOUBLE \n", yytext); }
{K_READ_INTEGER} { printf("%s: K_READ_INTEGER \n", yytext); }
{K_READ_STRING} { printf("%s: K_READ_STRING \n", yytext); }
{K_RETURN} { printf("%s: K_RETURN \n", yytext); }
{K_STRING} { printf("%s: K_STRING \n", yytext); }
{K_THEN} { printf("%s: K_THEN \n", yytext); }
{K_UNTIL} { printf("%s: K_UNTIL \n", yytext); }
{K_WHILE} { printf("%s: K_WHILE \n", yytext); }

{ASSIGN} { printf("%s: ASSIGN \n", yytext); }
{ASSIGN_PLUS} { printf("%s: ASSIGN_PLUS \n", yytext); }
{ASSIGN_MINUS} { printf("%s: ASSIGN_MINUS \n", yytext); }
{ASSIGN_MULTIPLY} { printf("%s: ASSIGN_MULTIPLY \n", yytext); }
{ASSIGN_DIVIDE} { printf("%s: ASSIGN_DIVIDE \n", yytext); }
{ASSIGN_MOD} { printf("%s: ASSIGN_MOD \n", yytext); }
{COMMENT} { printf("%s: COMMENT \n", yytext); }
{DAND} { printf("%s: DAND \n", yytext); }
{DOR} { printf("%s: DOR \n", yytext); }
{DEQ} { printf("%s: DEQ \n", yytext); }
{GEQ} { printf("%s: GEQ \n", yytext); }
{LEQ} { printf("%s: LEQ \n", yytext); }
{DECREMENT} { printf("%s: DECREMENT \n", yytext); }
{NE} { printf("%s: NE \n", yytext); }
{INCREMENT} { printf("%s: INCREMENT \n", yytext); }

{COMMA} { printf("%s: COMMA \n", yytext); }
{DIVIDE} { printf("%s: DIVIDE \n", yytext); }
{GT} { printf("%s: GT \n", yytext); }
{LBRACKET} { printf("%s: LBRACKET \n", yytext); }
{LCURLY} { printf("%s: LCURLY \n", yytext); }
{LPAREN} { printf("%s: LPAREN \n", yytext); }
{LT} { printf("%s: LT \n", yytext); }
{MINUS} { printf("%s: MINUS \n", yytext); }
{MOD} { printf("%s: MOD \n", yytext); }
{MULTIPLY} { printf("%s: MULTIPLY \n", yytext); }
{NOT} { printf("%s: NOT \n", yytext); }
{PERIOD} { printf("%s: PERIOD \n", yytext); }
{PLUS} { printf("%s: PLUS \n", yytext); }
{RBRACKET} { printf("%s: RBRACKET \n", yytext); }
{RCURLY} { printf("%s: RCURLY \n", yytext); }
{RPAREN} { printf("%s: RPAREN \n", yytext); }
{SEMI} { printf("%s: SEMI \n", yytext); }

{IDENTIFIER} { printf("%s: IDENTIFIER \n", yytext); }
{SCONSTANT} { printf("%s: SCONSTANT \n", yytext); }
{ICONSTANT} { printf("%s: ICONSTANT \n", yytext); }
{DCONSTANT} { printf("%s: DCONSTANT \n", yytext); }


%%   

int main(){
    printf("\n Enter string: ");
    yylex();
}

int yywrap(){
    return 1;
}
