
#ifndef TOKEN_H
#define TOKEN_H 

//=============  Structures  ====================
typedef struct token {
 int category;   /* the integer code returned by yylex */
 char *text;     /* the actual string (lexeme) matched */
 int lineno;     /* the line number on which the token occurs */
 char *filename; /* the source file in which the token occurs */
 int ival;       /* for integer constants, store binary value here */
 double dval;	   /* for real constants, store binary value here */
 char *sval;     /* for string constants, malloc space, de-escape, store */
								 /*    the string (less quotes and after escapes) here */
 } *tokenP;		

 typedef struct node{
	 tokenP tokPtr;
	 char *filename;
	 struct node *next;
 } *nodeP;
 
//=============  Prototypes  ====================
char *format_sval(char*);
tokenP createTok(int, char*, int, char*) ;
void popNode(nodeP*);
void pushNode(nodeP*, char*);
void addNode(nodeP*, tokenP);
void printTok(tokenP);
void printNode(nodeP*);
void printStack(nodeP*);
void wipeNodes(nodeP*);

#endif /* TOKEN_H */