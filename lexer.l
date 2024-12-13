%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"


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
COMMENT            [/]{2}[^\n]*
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

WHITESPACE [ \t\n]+

IDENTIFIER [a-zA-Z$_][a-zA-Z0-9$_]{0,31}
SCONSTANT "\""([^"\\]|\\.)*"\""
ICONSTANT [0-9]+
DCONSTANT (([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*))(d[-+]?[0-9]+)?
%%

{K_DO} { return K_DO; }
{K_DOUBLE} { return K_DOUBLE; }
{K_ELSE} { return K_ELSE; }
{K_EXIT} { return K_EXIT; }
{K_FUNCTION} { return K_FUNCTION; }
{K_IF} { return K_IF; }
{K_INTEGER} { return K_INTEGER; }
{K_PRINT_DOUBLE} { return K_PRINT_DOUBLE; }
{K_PRINT_INTEGER} { return K_PRINT_INTEGER; }
{K_PRINT_STRING} { return K_PRINT_STRING; }
{K_PROCEDURE} { return K_PROCEDURE; }
{K_PROGRAM} { return K_PROGRAM; }
{K_READ_DOUBLE} { return K_READ_DOUBLE; }
{K_READ_INTEGER} { return K_READ_INTEGER; }
{K_READ_STRING} { return K_READ_STRING; }
{K_RETURN} { return K_RETURN; }
{K_STRING} { return K_STRING; }
{K_THEN} { return K_THEN; }
{K_UNTIL} { return K_UNTIL; }
{K_WHILE} { return K_WHILE; }

{ASSIGN} { return ASSIGN; }
{ASSIGN_PLUS} { return ASSIGN_PLUS; }
{ASSIGN_MINUS} { return ASSIGN_MINUS; }
{ASSIGN_MULTIPLY} { return ASSIGN_MULTIPLY; }
{ASSIGN_DIVIDE} { return ASSIGN_DIVIDE; }
{ASSIGN_MOD} { return ASSIGN_MOD; }
{COMMENT} { /*Do Nothing*/ }
{DAND} { return DAND; }
{DOR} { return DOR; }
{DEQ} { return DEQ; }
{GEQ} { return GEQ; }
{LEQ} { return LEQ; }
{DECREMENT} { return DECREMENT; }
{NE} { return NE; }
{INCREMENT} { return INCREMENT; }

{COMMA} { return COMMA; }
{DIVIDE} { return DIVIDE; }
{GT} { return GT; }
{LBRACKET} { return LBRACKET; }
{LCURLY} { return LCURLY; }
{LPAREN} { return LPAREN; }
{LT} { return LT; }
{MINUS} { return MINUS; }
{MOD} { return MOD; }
{MULTIPLY} { return MULTIPLY; }
{NOT} { return NOT; }
{PERIOD} { return PERIOD; }
{PLUS} { return PLUS; }
{RBRACKET} { return RBRACKET; }
{RCURLY} { return RCURLY; }
{RPAREN} { return RPAREN; }
{SEMI} { return SEMI; }

{IDENTIFIER} {yylval.strValue = strdup(yytext);  return IDENTIFIER; }
{SCONSTANT} {yylval.strValue = strdup(yytext);  return SCONSTANT; }
{ICONSTANT} {yylval.strValue = strdup(yytext); return ICONSTANT; }
{DCONSTANT} {yylval.strValue = strdup(yytext);  return DCONSTANT; }

{WHITESPACE} { /*Do Nothing*/ }

%%   


int yywrap(){
    return 1;
}
