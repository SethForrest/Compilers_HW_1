/*
Seth Forrest
6 Sept 2017
main file for CS 445 Compilers assignment 1
adapted from https://compilers.iecc.com/crenshaw/
as well as github users park2331 and andschwa
*/

#include <stdlib.h>
#include <stdio.h>
#include "token.h"
#include "ytab.h"

extern FILE *yyin;
extern char *yytext;
extern tokenP yytoken;

char* fText = NULL;
nodeP fStack = NULL;

int main(int argc, char* argv[]){

	int i;
	tokenP fetch;
	int errorCode = -1;
	char *fileList[argc];
	struct node *tail = NULL;
		
	if(argc == 1){
		// /*error handling*/
		printf("I need a file.\n");
		return 0;
	}
	
	argc--; argv++; //skip program name
	for(i=0; i<argc; i++){
		// /*list names of files*/
		fileList[i] = argv[i];
	}

	for(i=0; i<argc; i++){
		yyin = fopen(fileList[i], "r");
		if(yyin == NULL){
			printf("invalid File: %s", fileList[i]);
			return 0;
		}
		fText = fileList[i];
		pushNode( &fStack, fText);
		yypush_buffer_state(yy_create_buffer(yyin, YY_BUFFER_SIZE));
	}
	
	// printf("\nFiles:\n");
	// printStack(&fStack);
	
	while(errorCode != 0){
		errorCode = yylex();
		if(yytoken != NULL){
			fetch = yytoken; // that is SO FETCH!!
			addNode(&tail, fetch); 
		} // quit trying to make fetch happen
	}
	
	printf("\nCategory\t Text\t\t LineNo\t FileName\t\t iVal/sVal\n");
	printf("----------------------------------------------------------------------------\n");
	if(tail == NULL){
		printf("Nothing to Print\n");
	} else {
		printNode(&tail);
	}
	printf("\n\n");
  return 0;
}







