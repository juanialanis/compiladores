#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "treeManagement.h"

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
                printf("Syntax error in line %d. Incompatible types for the operation %s. \n",tree->atr->line,getLabel(tree->atr->label));
                quick_exit(0);
            }
        }
    }
}

//method that if the type of an right branch and left branch are of the same type
int checkTypes(tree* tree){
    if(tree->right == NULL && tree->left == NULL){
        typeOf(tree);
        return 1;
    }
    return typeOf(tree->left) == typeOf(tree->right);
}   

int checkAssignaments(tree* tree){
    
    if(tree == NULL) return 1;

    if(!strcmp(getLabel(tree->atr->label),"DECL")){   
        if(!checkTypes(tree)){
            printf("Syntax error in line %d. Incompatible types for the initialization. \n",tree->atr->line);
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
                printf("Syntax error in line %d. Variable \"%s\" does not exist. \n", tree->atr->line ,tree->left->atr->text);
                quick_exit(0);
            }
        }
        if(!checkTypes(tree)){
            printf("Syntax error in line %d. Incompatible types for the assignment. \n",tree->atr->line);
            quick_exit(0);
        }
    }
    if(!strcmp(getLabel(tree->atr->label),"RETURN")){
        if(!checkTypes(tree->right)){
            printf("Syntax error in line %d. Incompatible types for the operation %s. \n",tree->atr->line,getLabel(tree->right->atr->label));
            quick_exit(0);
        }
    }
    checkOperationsAndAssignaments(tree->left);
    checkOperationsAndAssignaments(tree->right);
}

void setValue(char* name, int value){
  symbolTable* pointer = tableOfSymbols;
  while(pointer != NULL){
    if(!strcmp(name,pointer->cSymbol->text)){
      pointer->cSymbol->value = value;
    }
    pointer = pointer->next;
  }
}

int getValueOf(tree* tree){
    if(tree->left == NULL && tree->right == NULL){
        return tree->atr->value;
    }
    else{
        if(!strcmp(getLabel(tree->atr->label),"SUMA")){
            return getValueOf(tree->left) + getValueOf(tree->right);
        }
        if(!strcmp(getLabel(tree->atr->label),"MULTIPLICACION")){
            return getValueOf(tree->left) * getValueOf(tree->right);
        }
    }
}

void setResultOfOperations(tree* tree){
    if(tree != NULL){
        if(!strcmp(getLabel(tree->atr->label),"DECL") || !strcmp(getLabel(tree->atr->label),"STMT")){
            setValue(tree->left->atr->text,getValueOf(tree->right));
        }
        else if(!strcmp(getLabel(tree->atr->label),"RETURN")){
            if(tree->atr->type == Bool){
                printf("RETURN OF LINE %d RETURNS %s \n",tree->atr->line,getValueOf(tree->right) == 0 ? "FALSE" : "TRUE");
            }
            else{
                printf("RETURN OF LINE %d RETURNS %d \n",tree->atr->line,getValueOf(tree->right));
            }
        }
        setResultOfOperations(tree->left);
        setResultOfOperations(tree->right);   
    }
}
