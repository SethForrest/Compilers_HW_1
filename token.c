/*
Seth Forrest
6 Sept 2017
token file for CS 445 Compilers assignment 1
adapted from https://compilers.iecc.com/crenshaw/
as well as github users park2331 and andschwa

This file contains all functions related to tokens 
and token manipulation
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "token.h"
#include "ytab.h"

char *format_sval(char * string){
	int length = 0;
	char* strP = string;
	char* strLen = malloc(strlen(string));	
	while(*strP++ != '\"'){
		// iterate past first "
		strP++;
	}	
	while(*strP != '\"'){		//skip "
		if(strP[0] == '\\'){	// if escape
			char escape = strP[1]; // next char
			if(escape == 'n' || escape == 't' || escape == '\'' || escape == '\\' || escape == '\"' || escape == '\0'){
				strP = strP + 2;
			} 
			// switch(escape){
				// case 'n':
					// strP[0] = 10;
					// break;
					
			// }
		// strP = strP + 2;
		} else {
			strLen[length] = *strP;
			length++; strP++;
		}		
	}
	strLen[length] = '\0';
	strLen = realloc(strLen, length);
	return strLen;
}

tokenP createTok(int cat, char *message, int lineNum, char *file_name) {
	// Creates a token object and returns the pointer
	tokenP tP = malloc(sizeof(struct token));	
	tP -> ival = 0;
	tP -> sval = " ";
	tP -> category = cat;
	tP -> lineno = lineNum;	
	
	// addressed in class on 6 Sep, Lect 9
	tP -> text = malloc(strlen(message)+1); 
	strcpy(tP -> text, message);	
	tP -> filename = malloc(strlen(file_name)+1); 
	strcpy(tP -> filename, file_name);
	
	if(cat == ICON){
		tP -> ival = atoi(message);
	}	
	if(cat == STRING){
		tP -> sval = format_sval(message);
	}
	
	return tP;
}

void popNode(nodeP *head){
	// Pops the top off the stack of nodes
	nodeP tempP = NULL;
	tempP = *head;
	*head = (*head)-> next;
	free(tempP);
}

void pushNode(nodeP *head, char *file_name){
	// Pushes a node onto the stack of nodes
	nodeP tempP = (nodeP)malloc(sizeof(struct node));
	tempP -> filename = malloc(sizeof(file_name)+1); // +1 for \0 byte
	tempP -> next = NULL;
	strcpy(tempP -> filename, file_name);
	if( head == NULL){
		*head = tempP;
	} else {
		tempP -> next = *head;
		*head = tempP;
	}
}

void addNode(nodeP *head, tokenP nextPtr){
	nodeP tempP = malloc(sizeof(struct node));
	tempP -> tokPtr = nextPtr;
	tempP -> next = NULL;
	if( *head == NULL){
		*head = tempP;
	} else {
		nodeP move = *head;
		while(move -> next != NULL){
			move = move -> next;
		}
		move -> next = tempP;
	}
}

void printTok(tokenP tP){
	printf("%d\t\t %s\t\t %d\t %s\t %d\t %s\n", tP -> category, tP -> text, tP -> lineno, tP -> filename, tP -> ival, tP -> sval );
}

void printNode(nodeP *head){
	nodeP temp = *head;
	while(temp != NULL){
		printTok(temp -> tokPtr);
		temp = temp -> next;
	}
}

void printStack(nodeP *head){
	if(*head == NULL){
		printf("Stack Empty\n");
	} else {
		nodeP temp = *head;
		while(temp != NULL){
			printf("%s\n", temp -> filename);
			temp = temp -> next;
		}
	}
}

void wipeNodes(nodeP* head){
	nodeP temp = *head;
	while(temp != NULL){
		nodeP deleteMe = temp;
		temp = temp -> next;
		free(deleteMe);
	}
}











