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

struct treeNode{
    int item;
    int name;
    struct treeNode *first;
    struct treeNode *second;
};

typedef struct treeNode TREE_NODE;
typedef TREE_NODE *BINARY_TREE;

int evaluate(BINARY_TREE);
BINARY_TREE create_node(int, int, BINARY_TREE, BINARY_TREE);
void printTree(BINARY_TREE);
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
    K_PROGRAM IDENTIFIER LCURLY Function RCURLY {BINARY_TREE parseTree; int result; $$ = create_node(-1, PROGRAM, $4, NULL); printTree(parseTree);};

Function:
    K_FUNCTION Type IDENTIFIER LPAREN RPAREN LCURLY Inside RCURLY {$$ = create_node(-1, FUNCTION, $2, $7);};

Type:
    K_INTEGER {$$ = create_node($1, TYPE, NULL, NULL);}
    | K_DOUBLE {$$ = create_node($1, TYPE, NULL, NULL);}
    | K_STRING {$$ = create_node($1, TYPE, NULL, NULL);};
Inside:
    | Type IDENTIFIER SEMI Inside {$$ = create_node(-1, INSIDE, $1, $4);}
    | SetEqualTo SEMI Inside {$$ = create_node(-1, INSIDE, $1, $3);}
    | Print SEMI Inside {$$ = create_node(-1, INSIDE, $1, $3);};
SetEqualTo:
    IDENTIFIER ASSIGN Item {$$ = create_node(-1, SETEQUALTO, $3, NULL);}
    | IDENTIFIER ASSIGN_DIVIDE Item {$$ = create_node(-1, SETEQUALTO, $3, NULL);}
    | IDENTIFIER ASSIGN_MINUS Item {$$ = create_node(-1, SETEQUALTO, $3, NULL);}
    | IDENTIFIER ASSIGN_MOD Item {$$ = create_node(-1, SETEQUALTO, $3, NULL);}
    | IDENTIFIER ASSIGN_MULTIPLY Item {$$ = create_node(-1, SETEQUALTO, $3, NULL);}
    | IDENTIFIER ASSIGN_PLUS Item {$$ = create_node(-1, SETEQUALTO, $3, NULL);};
Print:
    K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN {$$ = create_node(-1, PRINT, NULL, NULL);}
    | K_PRINT_STRING LPAREN IDENTIFIER RPAREN {$$ = create_node(-1, PRINT, NULL, NULL);}
    | K_PRINT_DOUBLE LPAREN IDENTIFIER RPAREN {$$ = create_node(-1, PRINT, NULL, NULL);}
    | K_PRINT_INTEGER LPAREN ICONSTANT RPAREN {$$ = create_node(-1, PRINT, NULL, NULL);}
    | K_PRINT_STRING LPAREN SCONSTANT RPAREN {$$ = create_node(-1, PRINT, NULL, NULL);}
    | K_PRINT_DOUBLE LPAREN DCONSTANT RPAREN {$$ = create_node(-1, PRINT, NULL, NULL);};
Item:
    IDENTIFIER {$$ = create_node($1, ITEM, NULL, NULL);}
    | ICONSTANT {$$ = create_node($1, ITEM, NULL, NULL);}
    | SCONSTANT {$$ = create_node($1, ITEM, NULL, NULL);}
    | DCONSTANT {$$ = create_node($1, ITEM, NULL, NULL);};


%%
BINARY_TREE create_node(int item, int name, BINARY_TREE first, BINARY_TREE second){
    BINARY_TREE t;
    t = (BINARY_TREE)malloc(sizeof(TREE_NODE));
    t -> item = item;
    t -> name = name;
    t -> first = first;
    t -> second -> second;
    return (t);
}
int main(){
    printf("before\n");
    yyparse();
    printf("after\n");
    return 0;
}
void printTree(BINARY_TREE t){
    if(t == NULL){return;}
    printf("item: %d", t -> item);
    printf("nodeIdentifier: %d\n", t -> name);
    printTree(t -> first);
    printTree(t -> second);
}
