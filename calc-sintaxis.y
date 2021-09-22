%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "treeManagement.h"

extern int yylineno;


%}
 
%union { int i; char *s; struct treeN *tn;}
 
%token<i> INT
%token<s> ID
%token TINT TBOOL TTRUE TFALSE
%token RETURN

%type<tn> VALOR expr decl stmt stmts decls prog 
%type<i> type

%left '+'
%left '*'

 
%%
prog: decls stmts { 
                    node* root = newNode(0, yylineno, None, PROG, NULL);
                    $$ = newTree(root, $1, $2); 
                    checkAssignaments($$->left);
                    checkOperationsAndAssignaments($$->right);
                    // printf("La expresion es aceptada\n El arbol es: \n");
                    // printTree($$);
                    setResultOfOperations($$);
                };   

stmts: stmt             { $$ = $1; }

    | stmt stmts {
                    node* root = newNode(0, yylineno, None, SEMICOLON, NULL);
                    $$ = newTree(root, $1, $2); 
                }
    ;

stmt: ID '=' expr ';' {
                        symbolTable* pointer = tableOfSymbols;
                        node* root = newNode(0, yylineno, None, STMT, NULL);
                        node* sonL = newNode(0, yylineno, None, NONE, $1);
                        tree* newTL = newTree(sonL, NULL, NULL);
                        tree* treeCmp = newTree(root, newTL, $3);
                        $$ = treeCmp;
                    } 

    | RETURN expr ';'  {
                           
                            node* root = newNode(0, yylineno, None, RET, NULL);
                            $$ = newTree(root,NULL,$2);
                       }
    ;

decls: decl { $$ = $1;}
    | decl decls {
                    node* root = newNode(0, yylineno, None, SEMICOLON, NULL);
                    $$ = newTree(root, $1, $2); 
                }
    ;


decl: type ID '=' expr ';'{
                            node* root = newNode(0, yylineno, None, DECL, NULL);
                            node* sonL = newNode(0, yylineno, $1, NONE, $2);
                            symbolTable *st = newTableOfSymbols(sonL);
                            if(tableOfSymbols != NULL){
                                symbolTable* pointer = tableOfSymbols;
                                while(pointer != NULL){
                                    if(!strcmp(pointer->cSymbol->text,$2 )){
                                        printf("Syntax error in line %d. Variable \"%s\" already declared. \n", yylineno, $2);
                                        quick_exit(0);
                                    }
                                    if(pointer->next == NULL){
                                        pointer->next = st;
                                        break;
                                    }else{
                                        pointer = pointer->next;
                                    }
                                }
                            }
                            else{
                                tableOfSymbols = st;
                            }
                            tree* newTL = newTree(sonL, NULL, NULL);
                            tree* treeCmp = newTree(root, newTL, $4);
                            $$ = treeCmp;
                        } 
    ;
  
type: TINT    {$$ = Int;}
    | TBOOL   {$$ = Bool;}
    ;

expr: VALOR               

    | expr '+' expr {

                        node* root = newNode(0, yylineno, None, SUMA, NULL); 
                        tree* newTreeA = newTree(root, $1, $3);
                        $$ = newTreeA;
                    }

    | expr '*' expr {   
                        node* root = newNode(0, yylineno, None, MULTIPLICACION, NULL); 
                        tree* newTreeA = newTree(root, $1, $3);
                        $$ = newTreeA;
                    }   

    | '(' expr ')' { $$ = $2;}

    | ID {
        symbolTable* pointer = tableOfSymbols;
        while(pointer != NULL){
            if(!strcmp(pointer->cSymbol->text,$1 )){
                break;
            }else{
                pointer = pointer->next;
            }
            if(pointer == NULL){
                printf("Syntax error in line %d. Variable \"%s\" does not exist. \n", yylineno, $1);
                quick_exit(0);
            }
        }
        node* root = pointer->cSymbol; 
        $$ = newTree(root, NULL, NULL);
    }
    ;

VALOR : INT {
        node* root = newNode($1, 0, Int, NONE, NULL); 
        $$ = newTree(root, NULL, NULL);
    }
| TTRUE {
        node* root = newNode(1, 0, Bool, NONE, NULL);
        $$ = newTree(root, NULL, NULL);
    }
| TFALSE { 
        node* root = newNode(0, 0, Bool, NONE, NULL);
        $$ = newTree(root, NULL, NULL);
    }
;

 
%%
