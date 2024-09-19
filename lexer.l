%{
#include<stdio.h>
#include <stdlib.h>

#define K_DO               1
#define K_DOUBLE           2
#define K_ELSE             3
#define K_EXIT             4
#define K_FUNCTION         5
#define K_IF               6
#define K_INTEGER          7
#define K_PRINT_DOUBLE     8
#define K_PRINT_INTEGER    9
#define K_PRINT_STRING     10
#define K_PROCEDURE        11
#define K_PROGRAM          12
#define K_READ_DOUBLE      13
#define K_READ_INTEGER     14
#define K_READ_STRING      15
#define K_RETURN           16
#define K_STRING           17
#define K_THEN             18
#define K_UNTIL            19
#define K_WHILE            20
#define ASSIGN             21
#define ASSIGN_PLUS        22
#define ASSIGN_MINUS       23
#define ASSIGN_MULTIPLY    24
#define ASSIGN_DIVIDE      25
#define ASSIGN_MOD         26
#define COMMENT            27
#define DAND               28
#define DOR                29
#define DEQ                30
#define GEQ                31
#define LEQ                32
#define DECREMENT          33
#define NE                 34
#define INCREMENT          35
#define COMMA              36
#define DIVIDE             37
#define GT                 38
#define LBRACKET           39
#define LCURLY             40
#define LPAREN             41
#define LT                 42
#define MINUS              43
#define MOD                44
#define MULTIPLY           45
#define NOT                46
#define PERIOD             47
#define PLUS               48
#define RBRACKET           49
#define RCURLY             50
#define RPAREN             51
#define SEMI               52

#define IDENTIFIER 53
#define SCONSTANT 54
#define ICONSTANT 55
#define DCONSTANT 56




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
{COMMENT} { return COMMENT; }
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

{IDENTIFIER} { return IDENTIFIER; }
{SCONSTANT} { return SCONSTANT; }
{ICONSTANT} { return ICONSTANT; }
{DCONSTANT} { return DCONSTANT; }


%%   

int main(){
    printf("\n Enter string: ");
    yylex();
}

int yywrap(){
    return 1;
}
