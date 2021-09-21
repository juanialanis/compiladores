%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

enum TLabel { NONE, DECL, STMT, SUMA, MULTIPLICACION, RESTA, SEMICOLON, PROG, RET};

enum TType {None, Int, Bool };


//struct that defines a node*
typedef struct infoNode {
    int value;
    int line;
    enum TType type;
    enum TLabel label;
    char* text;
} node;

//struct that defines a tree
typedef struct treeN {
    node* atr;
    struct treeN* left;
    struct treeN* right;
} tree;
 
//struct that defines a symbols table
typedef struct symbolTable{
    node* cSymbol;
    struct symbolTable* next;
} symbolTable;


//method that creates a new table of symbols
symbolTable* newTableOfSymbols(node* s){
    symbolTable* newTable = malloc(sizeof(symbolTable));
    newTable->cSymbol = s;
    newTable->next = NULL;
    return newTable;
}


//method that returns the string equivalent to the types
char* getType(enum TType type){
    switch(type){
        case None: return "None";
        case Bool: return "Bool";
        case Int: return "Int";
    }
}


//method that returns the string equivalent to the labels
char* getLabel(enum TLabel label){
    switch(label){
        case NONE: return "NONE";
        case DECL: return "DECL";
        case STMT: return "STMT";
        case SUMA: return "SUMA";
        case MULTIPLICACION: return "MULTIPLICACION";
        case RESTA: return "RESTA";
        case RET: return "RETURN";
        case PROG: return "PROG";
        case SEMICOLON: return "SEMICOLON";
    }
}

//table of symbols
symbolTable* tableOfSymbols = NULL;

//method that create a new tree
tree* newTree(node* newatr, tree *newleft, tree *newright){
    tree *newTree = (tree*) malloc(sizeof(tree));
    newTree->atr = newatr;
    newTree->left = newleft;    
    newTree->right = newright;
    return newTree;
}

node* newNode(int value,int line, enum TType type, enum TLabel label, char* text){
    node* newNode = malloc(sizeof(node));
    newNode->value = value;
    newNode->line = line;
    newNode->type = type;
    newNode->label = label;
    newNode->text = text;
    return newNode;
}

//as the concatenation gave us a lot of problems, we finally decided to use this option that we found in
//https://es.stackoverflow.com/questions/146607/c%C3%B3mo-concatenar-cadenas-de-car%C3%A1cteres-sin-usar-la-funci%C3%B3n-strcat
// and later has modified by our needs
char* cat(char *s1, char *s2) {
  if (!s1 || !s2)
    return s1? s1: s2;

  int len = strlen(s1), len2 = strlen(s2);
  char* result = malloc(len+len2);
  int x;
  for(int i = 0; i < len; i++){
      result[i] = s1[i];
      x = i + 1;
  }
  for(int j = 0; j < len2; j++){
      result[(x+j)] = s2[j];
  }
  return result; 
}

//method that take an int value and parse it to char*
char* getValue(int i) {
    char* result = malloc(1);
    result[0] = '0'+i;
    return result;
}

//method that take an node* of an tree and parse it to a char* with all the fields of the tree
char* treetoString(node* atr){
    char* value = cat("Value: ", getValue(atr->value));
    char* type = getType(atr->type);
    char* text = ",Type: ";
    char* result = cat(text,type);
    result = cat(value,result);
    text = ",Label: ";
    result = cat(result,text);
    char* label = getLabel(atr->label);
    result = cat (result, label);
    char* line = cat(",Line: ", getValue(atr->line));
    result = cat(result,line);
    result = cat(result, ",Text: ");
    result = cat(result,atr->text != NULL ? atr->text : "");
    return result;
}

//method that generates a sample of the tree
void printTree(tree* tree){
    printf("{ \n node*: { %s }\n", treetoString(tree->atr));
    printf("\n HI: \n");
    tree->left != NULL ? printTree(tree->left) : printf("NULL \n");
    printf("\n HD: \n");
    tree->right != NULL ? printTree(tree->right) : printf("NULL \n");
    printf("}\n");
}


//method that returns the type of an sub-tree
enum TType typeOf(tree* tree){
    if(tree->left == NULL && tree->right == NULL){
        if(tree->atr->text != NULL){
            symbolTable* pointer = tableOfSymbols;
            while(pointer != NULL){
                if(!strcmp(pointer->cSymbol->text,tree->atr->text)){
                    return pointer->cSymbol->type;
                }
                pointer = pointer->next;
            }
        }
        else{
            return tree->atr->type;   
        }
    }
    else{
        if(!strcmp(getLabel(tree->atr->label),"SUMA") || !strcmp(getLabel(tree->atr->label),"MULTIPLICACION")){
            if(typeOf(tree->left) == typeOf(tree->right)){
                return typeOf(tree->left);
            }
            else{
                printf("Incompatible types for the operation %s \n", getLabel(tree->atr->label));
                quick_exit(0);
            }
        }
    }
}

//method that if the type of an right branch and left branch are of the same type
int checkTypes(tree* tree){
    return typeOf(tree->left) == typeOf(tree->right);
}   

int checkAssignaments(tree* tree){
    
    if(tree == NULL) return 1;

    if(!strcmp(getLabel(tree->atr->label),"DECL")){   
        if(!checkTypes(tree)){
            printf("One of the types are incorrect \"%s\" != (\"%d\",\"%s\") \n",getType(tree->left->atr->type),tree->right->atr->value,getType(tree->right->atr->type));
            quick_exit(0);
        }
    }
    checkAssignaments(tree->left);
    checkAssignaments(tree->right);
}


int checkOperationsAndAssignaments(tree* tree){
    if(tree == NULL) return 1;

    if(!strcmp(getLabel(tree->atr->label),"STMT")){
        symbolTable* pointer = tableOfSymbols;
        while(pointer != NULL){
            if(!strcmp(pointer->cSymbol->text,tree->left->atr->text )){
                break;
            }else{
                pointer = pointer->next;
            }
            if(pointer == NULL){
                printf("Variable \"%s\" not exists. \n", tree->left->atr->text);
                quick_exit(0);
            }
        }
        if(!checkTypes(tree)){
            printf("The type of the variable \"%s\" is incompatible with the value (\"%d\",\"%s\") \n",tree->left->atr->text,tree->right->atr->value,getType(tree->right->atr->type));
            quick_exit(0);
        }
    }
    checkOperationsAndAssignaments(tree->left);
    checkOperationsAndAssignaments(tree->right);
}
%}
 
%union { int i; char *s; struct treeN *tn;}
 
%token<i> INT
%token<s> ID
%token TINT TBOOL TTRUE TFALSE
%token RETURN

%type<tn> VALOR expr decl stmt stmts decls prog returnd
%type<i> type

%left '*'

 
%%
prog: decls stmts { 
                    node* root = newNode(0, 0, None, PROG, NULL);
                    $$ = newTree(root, $1, $2); 
                    printf("La expresion es aceptada\n El arbol es: \n");
                    checkAssignaments($$->left);
                    checkOperationsAndAssignaments($$->right);
                    printTree($$);

                };   

stmts: stmt             { $$ = $1; }

    | stmt stmts {
                    node* root = newNode(0, 0, None, SEMICOLON, NULL);
                    $$ = newTree(root, $1, $2); 
                }
    ;

stmt: ID '=' expr ';' {
                        symbolTable* pointer = tableOfSymbols;
                        node* root = newNode(0, 0, None, STMT, NULL);
                        node* sonL = newNode(0, 0, None, NONE, $1);
                        tree* newTL = newTree(sonL, NULL, NULL);
                        tree* treeCmp = newTree(root, newTL, $3);
                        $$ = treeCmp;
                    } 

    | RETURN expr ';'  {
                           
                            node* root = newNode(0, 0, None, RET, NULL);
                            $$ = newTree(root,NULL,$2);
                       }
    ;

decls: decl { $$ = $1;}
    | decl decls {
                    node* root = newNode(0, 0, None, SEMICOLON, NULL);
                    $$ = newTree(root, $1, $2); 
                }
    | decl returnd {
                    node* root = newNode(0, 0, None, SEMICOLON, NULL);
                    $$ = newTree(root, $1, $2); 
                }
    ;

returnd: RETURN expr ';' decls { 
                                node* root = newNode(0, 0, None, SEMICOLON, NULL);
                                node* sonL = newNode(0, 0, None, RET, NULL);
                                tree* treeL = newTree(sonL,NULL, $2);
                                $$ = newTree(root, treeL, $4);
                                }


        | RETURN expr ';' { 
                                node* root = newNode(0, 0, None, SEMICOLON, NULL);
                                node* sonL = newNode(0, 0, None, RET, NULL);
                                tree* treeL = newTree(sonL,NULL, $2);
                                $$ = newTree(root, treeL, NULL);
                                }


decl: type ID '=' expr ';'{
                            node* root = newNode(0, 0, None, DECL, NULL);
                            node* sonL = newNode(0, 0, $1, NONE, $2);
                            symbolTable *st = newTableOfSymbols(sonL);
                            if(tableOfSymbols != NULL){
                                symbolTable* pointer = tableOfSymbols;
                                while(pointer != NULL){
                                    if(!strcmp(pointer->cSymbol->text,$2 )){
                                        printf("Variable \"%s\" already declared. \n", $2);
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

                        node* root = newNode(0, 0, None, SUMA, NULL); 
                        tree* newTreeA = newTree(root, $1, $3);
                        $$ = newTreeA;
                    }

    | expr '*' expr {   
                        node* root = newNode(0, 0, None, MULTIPLICACION, NULL); 
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
                printf("Variable \"%s\" not exists. \n", $1);
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