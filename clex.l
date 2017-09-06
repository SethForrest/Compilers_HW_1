O        [0-7]
D        [0-9]
L        [a-zA-Z_]
H        [a-fA-F0-9]
E        [Ee][+-]?{D}+
FS       (f|F|l|L)
IS       (u|U|l|L)
W        [ \t\f]*
LIT      \"(\\.|[^\\"])*\"

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "ytab.h"
#include "token.h"

extern int yychar;

void lexerr(char *s);
void handle_include();

/* #define DEBUG */

int line_num = 1;
int errors;
int included_iostream = 0;
FILE *saved_yyin;
%}

%%

\n                      { line_num++; }
[ \t\f]+                { }

"break"                 { return BREAK; }
"case"                  { return CASE; }
"char"                  { return CHAR; }
"const"                 { return CONST; }
"continue"              { return CONTINUE; }
"default"               { return DEFAULT; }
"do"                    { return DO; }
"double"                { return DOUBLE; }
"else"                  { return ELSE; }
"enum"                  { return ENUM; }
"extern"                { return EXTERN; }
"float"                 { return FLOAT; }
"for"                   { return FOR; }
"goto"                  { return GOTO; }
"if"                    { return IF; }
"int"                   { printf("%s \n",yytext); return INT; }
"long"                  { return LONG; }
"register"              { return REGISTER; }
"return"                { return RETURN; }
"short"                 { return SHORT; }
"signed"                { return SIGNED; }
"sizeof"                { return SIZEOF; }
"static"                { return STATIC; }
"struct"                { return STRUCT; }
"switch"                { return SWITCH; }
"typedef"               { return TYPEDEF; }
"union"                 { return UNION; }
"unsigned"              { return UNSIGNED; }
"void"                  { return VOID; }
"volatile"              { return VOLATILE; }
"while"                 { return WHILE; }

{L}({L}|{D})*           { return IDENTIFIER; }


0[xX]{H}+{IS}?          { lexerr("Hex not supported\n"); }

0{O}+{IS}?              { lexerr("Octal not supported\n"); }

{D}+{IS}?               { return ICON; }

'(\\.|[^\\'])+'         { return CCON; }

{D}+{E}{FS}?            { return FCON; }
{D}*"."{D}+({E})?{FS}?  { return FCON; }
{D}+"."{D}*({E})?{FS}?  { return FCON; }

{LIT}                   { return STRING; }

"#include"[ ]*\"[^\\"]+\"  { handle_include(); }

"#include <iostream>"   { included_iostream = 1; }

">>="                   { return SRASN; }
"<<="                   { return SLASN; }
"+="                    { return PLASN; }
"-="                    { return MIASN; }
"*="                    { return MUASN; }
"/="                    { return DIASN; }
"%="                    { return MOASN; }
"&="                    { return ANASN; }
"^="                    { return ERASN; }
"|="                    { return ORASN; }
">>"                    { return SHR; }
"<<"                    { return SHL; }
"++"                    { return INCOP; }
"--"                    { return DECOP; }
"->"                    { return FOLLOW; }
"&&"                    { return ANDAND; }
"||"                    { return OROR; }
"<="                    { return LE; }
">="                    { return GE; }
"=="                    { return EQ; }
"!="                    { return NE; }
";"                     { return SM; }
"{"                     { return LC; }
"}"                     { return RC; }
","                     { return CM; }
":"                     { return COLON; }
"="                     { return ASN; }
"("                     { return LP; }
")"                     { return RP; }
"["                     { return LB; }
"]"                     { return RB; }
"."                     { return DOT; }
"&"                     { return AND; }
"!"                     { return BANG; }
"~"                     { return NOT; }
"-"                     { return MINUS; }
"+"                     { return PLUS; }
"*"                     { return MUL; }
"/"                     { return DIV; }
"%"                     { return MOD; }
"<"                     { return LT; }
">"                     { return GT; }
"^"                     { return ER; }
"|"                     { return OR; }
"?"                     { return QUEST; }
%%

void lexerr(char *s)
{
	errors++;

	fprintf(stderr, "%s: lexical error", s);

	/* to do: add mechanism for reporting file name and line number */

	fprintf(stderr, ", token = \"%s\"\n", yytext);
}

/*
 * Return 1 if done, 0 if yyin points at more input
 */
int yywrap()
{
   return 1;
}

void handle_include()
{
   char *newfilename = malloc(strlen(yytext)+1-strlen("#include \"\""));
   saved_yyin = yyin;
   char *fname = strchr(yytext, '\"')+1;
   fname[strlen(fname)-1] = '\0';
   // fprintf(stdout, "included filename '%s'\n", fname); fflush(stdout);
   yyin = fopen(fname,"r");
   if (yyin == NULL) {
     lexerr("cannot open include file");
     exit(1);
   }
}


void create_token(int category){
	make_token(	category, yylineno, yytext);
}

struct token *make_token(
											int category, 
											int lineno, 
											const char *text
	){
	struct token *t = malloc(sizeof(*t));
	if (t == NULL)
		log_error("create_token(): could not malloc token");

	t->category = category;
	t->lineno = lineno;
	t->text = strdup(text);
	t->filename = strdup(file_name);

	// switch(category) {
	// case INTEGER:
		// t->ival = atoi(text);
		// break;
	// case FALSE:
		// t->ival = 0;
		// break;
	// case TRUE:
		// t->ival = 1;
		// break;
	// case FLOATING:
		// t->fval = atof(text);
		// break;
	// case STRING:
		// t->ssize = 0; /* append null later */
		// token_sval_size = TEXT_CHUNK_SIZE;
		// t->sval = calloc(token_sval_size, sizeof(char));
		// break;
	// default:
		// break;
	// }

	return t;
}

void print_token(struct token *t)
{
		char *filename = strdup(t->filename);
		log_assert(filename);

		printf("%-5d%-12s%-12s%s ",
		       t->lineno,
		       basename(filename),
		       print_category(t->category),
		       t->text);

		free(filename);

		if (t->category == INTEGER)
			printf("-> %d", t->ival);
		else if (t->category == FLOATING)
			printf("-> %f", t->fval);
		else if (t->category == CHARACTER)
			printf("-> %c", t->ival);
		else if (t->category == STRING)
			printf("-> %s", t->sval);

		printf("\n");
}












