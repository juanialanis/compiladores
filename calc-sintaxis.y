%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

enum TLabel { NONE, DECL, STMT, SUMA, MULTIPLICACION, RESTA, SEMICOLON, PROG, RET};

enum TType {None, Int, Bool };


//struct that defines a node
typedef struct infoNode {
    int value;
    int line;
    enum TType type;
    enum TLabel label;
    char* text;
    struct symbolTable* symbol;
} node;

//struct that defines a tree
typedef struct treeN {
    node atr;
    struct treeN* left;
    struct treeN* right;
} tree;

typedef struct symbol{
    char* name;
    enum TType type;
} symbol;
 

typedef struct symbolTable{
    symbol* cSymbol;
    struct symbolTable* next;
} symbolTable;


symbolTable* newTableOfSymbols(symbol* s){
    symbolTable* newTable = malloc(sizeof(symbolTable));
    newTable->cSymbol = s;
    newTable->next = NULL;
    return newTable;
}

symbol* newSymbol(enum TType type, char* name){
    symbol* s = malloc(sizeof(symbol));
    s->name = name;
    s->type = type;
    return s;
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

symbolTable* tableOfSymbols = NULL;

//method that create a new tree
tree* newTree(node newatr, tree *newleft, tree *newright){
    tree *newTree = (tree*) malloc(sizeof(tree));
    newTree->atr = newatr;
    newTree->left = newleft;    
    newTree->right = newright;
    return newTree;
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

//method that take an node of an tree and parse it to a char* with all the fields of the tree
char* treetoString(node atr){
    char* value = cat("Value: ", getValue(atr.value));
    char* type = getType(atr.type);
    char* text = ",Type: ";
    char* result = cat(text,type);
    result = cat(value,result);
    text = ",Label: ";
    result = cat(result,text);
    char* label = getLabel(atr.label);
    result = cat (result, label);
    char* line = cat(",Line: ", getValue(atr.line));
    result = cat(result,line);
    result = cat(result, ",Text: ");
    result = cat(result,atr.text != NULL ? atr.text : "");
    if(atr.symbol != NULL){
        result = cat(cat(result," ,Symbol: {Name: "), atr.symbol->cSymbol->name);
        result = cat(cat(result, ", Type: "), getType(atr.symbol->cSymbol->type));
        result = cat(result, "}");
    }
    return result;
}

//method that generates a sample of the tree
void printTree(tree* tree){
    printf("{ \n Node: { %s }\n", treetoString(tree->atr));
    printf("\n HI: \n");
    tree->left != NULL ? printTree(tree->left) : printf("NULL \n");
    printf("\n HD: \n");
    tree->right != NULL ? printTree(tree->right) : printf("NULL \n");
    printf("}\n");
}

void printTable(symbolTable* table){
    symbol* s = table->cSymbol;
    char* name = s->name;
    enum TType type = s->type;
    printf("Symbol: {name: %s, type: %d }\n",name,type);
    if(table->next != NULL){
        printTable(table->next);
    }
}



enum TType typeOf(tree* tree){
    if(tree->left == NULL && tree->right == NULL){
        if(tree->atr.text != NULL){
            symbolTable* pointer = tableOfSymbols;
            while(pointer != NULL){
                if(!strcmp(pointer->cSymbol->name,tree->atr.text)){
                    return pointer->cSymbol->type;
                }
                pointer = pointer->next;
            }
        }
        else{
            return tree->atr.type;   
        }
    }
    else{
        if(!strcmp(getLabel(tree->atr.label),"SUMA") || !strcmp(getLabel(tree->atr.label),"MULTIPLICACION")){
            if(typeOf(tree->left) == typeOf(tree->right)){
                return typeOf(tree->left);
            }
            else{
                printf("Incompatible types for the operation %s \n", getLabel(tree->atr.label));
                quick_exit(0);
            }
        }
    }
}

int checkTypes(tree* tree){
    return typeOf(tree->left) == typeOf(tree->right);
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
                    node root = {0, 0, None, PROG, NULL};
                    $$ = newTree(root, $1, $2); 
                    printf("La expresion es aceptada\n El arbol es: \n");
                    // printTree($$);
                };   

stmts: stmt             { $$ = $1; }

    | stmt stmts {
                    node root = {0, 0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    ;

stmt: ID '=' expr ';' {
                        symbolTable* pointer = tableOfSymbols;
                        while(pointer != NULL){
                            if(!strcmp(pointer->cSymbol->name,$1 )){
                                break;
                            }
                            pointer = pointer->next;
                            if(pointer == NULL){
                                printf("The variable \"%s\" is not defined\n",$1);
                                quick_exit(0);
                            }
                        }
                        node root = {0, 0, None, STMT, NULL};
                        node sonL = {0, 0, None, NONE, $1};
                        tree* newTL = newTree(sonL, NULL, NULL);
                        tree* treeCmp = newTree(root, newTL, $3); 
                        if(!checkTypes(treeCmp)){
                            printf("The variable type of %s is incompatible with the type of the expression \n ", $1 );
                            quick_exit(0);
                        }
                        $$ = treeCmp;
                    } 

    | RETURN expr ';'  {
                           
                            node root = {0, 0, None, RET, NULL};
                            $$ = newTree(root,NULL,$2);
                       }
    ;

decls: decl { $$ = $1;}
    | decl decls {
                    node root = {0, 0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    | decl returnd {
                    node root = {0, 0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    ;

returnd: RETURN expr ';' decls { 
                                node root = {0, 0, None, SEMICOLON, NULL};
                                node sonL = {0, 0, None, RET, NULL};
                                tree* treeL = newTree(sonL,NULL, $2);
                                $$ = newTree(root, treeL, $4);
                                }


        | RETURN expr ';' stmts { 
                                node root = {0, 0, None, SEMICOLON, NULL};
                                node sonL = {0, 0, None, RET, NULL};
                                tree* treeL = newTree(sonL,NULL, $2);
                                $$ = newTree(root, treeL, $4);
                                }

decl: type ID '=' expr ';'{
                            symbol* s = newSymbol($1,$2);
                            symbolTable *st = newTableOfSymbols(s);
                            if(tableOfSymbols != NULL){
                                symbolTable* pointer = tableOfSymbols;
                                while(pointer->next  != NULL){ 
                                    if(!strcmp(pointer->cSymbol->name,$2)){
                                        printf("Variable \"%s\" already declared \n", $2);
                                        quick_exit(0);
                                    } 
                                    pointer = pointer->next;
                                }
                                pointer->next = st;
                            }
                            else{
                                tableOfSymbols = st;
                            }
                            node root = {0, 0, None, DECL, NULL};
                            node sonL = {0, 0, $1, NONE, $2, st};
                            tree* newTL = newTree(sonL, NULL, NULL);
                            tree* treeCmp = newTree(root, newTL, $4);
                            if(typeOf($4) != sonL.type){
                                printf("The inizialitation value type does not match with the type of the variable \"%s\"\n ", $2 );
                                quick_exit(0);
                            }
                            $$ = treeCmp;
                        } 
    ;
  
type: TINT    {$$ = Int;}
    | TBOOL   {$$ = Bool;}
    ;

expr: VALOR               

    | expr '+' expr {

                        node root = {0, 0, None, SUMA, NULL}; 
                        tree* newTreeA = newTree(root, $1, $3);
                        if(!checkTypes(newTreeA)){
                            printf("The types of the addition are incorrect \n");
                            quick_exit(0);
                        };
                        $$ = newTreeA;
                    }

    | expr '*' expr {   
                        node root = {0, 0, None, MULTIPLICACION, NULL}; 
                        tree* newTreeA = newTree(root, $1, $3);
                        if(!checkTypes(newTreeA)){
                            printf("The types of the multiplication are incorrect \n");
                            quick_exit(0);
                        };
                        $$ = newTreeA;
                    }   

    | '(' expr ')' { $$ = $2;}

    | ID {
        node root = {0, 0, None, NONE, $1}; 
        $$ = newTree(root, NULL, NULL);
    }
    ;

VALOR : INT {
        node root = {$1, 0, Int, NONE, NULL}; 
        $$ = newTree(root, NULL, NULL);
    }
| TTRUE {
        node root = {1, 0, Bool, NONE, NULL};
        $$ = newTree(root, NULL, NULL);
    }
| TFALSE { 
        node root = {0, 0, Bool, NONE, NULL};
        $$ = newTree(root, NULL, NULL);
    }
;

 
%%