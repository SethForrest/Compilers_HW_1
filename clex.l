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
#include "token.h"
#include "ytab.h"

#define TRUE 1
#define FALSE 0

extern int yychar;
extern char *fText;
extern nodeP fStack;
extern FILE *yyin;

tokenP yytoken;
FILE *yyin_mem;
int LineNo_mem;
char* fText_mem;

int ctime = FALSE;
int cmath = FALSE;
int string = FALSE;
int iomanip = FALSE;
int cstdlib = FALSE;
int cstring = FALSE;
int fstream = FALSE;
int iostream = FALSE;

void lexerr(char *s);
void handle_include();
int handle_EOF();
void tokenize(int);

/* #define DEBUG */
int line_num = 1;
int errors = 0;
FILE *saved_yyin;
%}

%%

\n                      		{ line_num++; }
[ \t\f]+                		{ }
\/[\/]+.*										{ }
"/*"([^*]*|"*"*+[^/]*)"*/" 	{ }

"break"                 { tokenize(BREAK); 		return BREAK; }
"case"                  { tokenize(CASE); 		return CASE; }
"char"                  { tokenize(CHAR); 		return CHAR; }
"const"                 { tokenize(CONST); 		return CONST; }
"continue"              { tokenize(CONTINUE); return CONTINUE; }
"default"               { tokenize(DEFAULT); 	return DEFAULT; }
"do"                    { tokenize(DO); 			return DO; }
"double"                { tokenize(DOUBLE); 	return DOUBLE; }
"else"                  { tokenize(ELSE); 		return ELSE; }
"enum"                  { tokenize(ENUM); 		return ENUM; }
"extern"                { tokenize(EXTERN); 	return EXTERN; }
"float"                 { tokenize(FLOAT); 		return FLOAT; }
"for"                   { tokenize(FOR); 			return FOR; }
"goto"                  { tokenize(GOTO); 		return GOTO; }
"if"                    { tokenize(IF); 			return IF; }
"int"                   { tokenize(INT); 			return INT; }
"long"                  { tokenize(LONG); 		return LONG; }
"register"              { tokenize(REGISTER); return REGISTER; }
"return"                { tokenize(RETURN); 	return RETURN; }
"short"                 { tokenize(SHORT); 		return SHORT; }
"signed"                { tokenize(SIGNED); 	return SIGNED; }
"sizeof"                { tokenize(SIZEOF); 	return SIZEOF; }
"static"                { tokenize(STATIC); 	return STATIC; }
"struct"                { tokenize(STRUCT); 	return STRUCT; }
"switch"                { tokenize(SWITCH); 	return SWITCH; }
"typedef"               { tokenize(TYPEDEF); 	return TYPEDEF; }
"union"                 { tokenize(UNION); 		return UNION; }
"unsigned"              { tokenize(UNSIGNED); return UNSIGNED; }
"void"                  { tokenize(VOID); 		return VOID; }
"volatile"              { tokenize(VOLATILE); return VOLATILE; }
"while"                 { tokenize(WHILE); 		return WHILE; }


{L}({L}|{D})*           { tokenize(IDENTIFIER); return IDENTIFIER; }
0[xX]{H}+{IS}?          { lexerr("Hex not supported\n"); }
0{O}+{IS}?              { lexerr("Octal not supported\n"); }

{D}+{IS}?               { tokenize(ICON); 		return ICON; }
'(\\.|[^\\'])+'         { tokenize(CCON); 		return CCON; }
{D}+{E}{FS}?            { tokenize(FCON); 		return FCON; }
{D}*"."{D}+({E})?{FS}?  { tokenize(FCON); 		return FCON; }
{D}+"."{D}*({E})?{FS}?  { tokenize(FCON); 		return FCON; }
{LIT}                   { tokenize(STRING); 	return STRING; }

"#include <ctime>"				{ctime = TRUE;}
"#include <cmath>"				{cmath = TRUE;}
"#include <string>"				{string = TRUE;}
"#include <iomanip>"			{iomanip = TRUE;}
"#include <cstdlib>"			{cstdlib = TRUE;}
"#include <cstring>"			{cstring = TRUE;}
"#include <fstream>"			{fstream = TRUE;}
"#include <iostream>"			{iostream = TRUE;}
"#include "+{LIT}  				{handle_include();}

"using namespace std;"			{ }

">>="                   { tokenize(SRASN); 	return SRASN; }
"<<="                   { tokenize(SLASN); 	return SLASN; }
"+="                    { tokenize(PLASN); 	return PLASN; }
"-="                    { tokenize(MIASN); 	return MIASN; }
"*="                    { tokenize(MUASN); 	return MUASN; }
"/="                    { tokenize(DIASN); 	return DIASN; }
"%="                    { tokenize(MOASN); 	return MOASN; }
"&="                    { tokenize(ANASN); 	return ANASN; }
"^="                    { tokenize(ERASN); 	return ERASN; }
"|="                    { tokenize(ORASN); 	return ORASN; }
">>"                    { tokenize(SHR); 		return SHR; }
"<<"                    { tokenize(SHL); 		return SHL; }
"++"                    { tokenize(INCOP); 	return INCOP; }
"--"                    { tokenize(DECOP); 	return DECOP; }
"->"                    { tokenize(FOLLOW); return FOLLOW; }
"&&"                    { tokenize(ANDAND); return ANDAND; }
"||"                    { tokenize(OROR); 	return OROR; }
"<="                    { tokenize(LE); 		return LE; }
">="                    { tokenize(GE); 		return GE; }
"=="                    { tokenize(EQ); 		return EQ; }
"!="                    { tokenize(NE); 		return NE; }
";"                     { tokenize(SM); 		return SM; }
"{"                     { tokenize(LC); 		return LC; }
"}"                     { tokenize(RC); 		return RC; }
","                     { tokenize(CM); 		return CM; }
":"                     { tokenize(COLON); 	return COLON; }
"="                     { tokenize(ASN); 		return ASN; }
"("                     { tokenize(LP); 		return LP; }
")"                     { tokenize(RP); 		return RP; }
"["                     { tokenize(LB);			return LB; }
"]"                     { tokenize(RB); 		return RB; }
"."                     { tokenize(DOT); 		return DOT; }
"&"                     { tokenize(AND); 		return AND; }
"!"                     { tokenize(BANG); 	return BANG; }
"~"                     { tokenize(NOT); 		return NOT; }
"-"                     { tokenize(MINUS); 	return MINUS; }
"+"                     { tokenize(PLUS); 	return PLUS; }
"*"                     { tokenize(MUL); 		return MUL; }
"/"                     { tokenize(DIV); 		return DIV; }
"%"                     { tokenize(MOD); 		return MOD; }
"<"                     { tokenize(LT); 		return LT; }
">"                     { tokenize(GT); 		return GT; }
"^"                     { tokenize(ER); 		return ER; }
"|"                     { tokenize(OR); 		return OR; }
"?"                     { tokenize(QUEST); 	return QUEST; }
"#"											{ }

<<EOF>>                 { 

  yypop_buffer_state();
  popNode(&fStack);
  yylineno = 1;
	line_num = 1;
  if (fStack == NULL) {
    yyterminate();    
    printf("ALL FILES PARSED!\n");
  }

  if (!YY_CURRENT_BUFFER) {
    printf("NO MORE BUFFERS!\n");
    yyterminate();
  } 
}
%%

void tokenize(int cat){
	fText = fStack -> filename;
	yytoken = createTok(cat, yytext, line_num, fText);
};

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
   fprintf(stdout, "included filename '%s'\n", fname); fflush(stdout);
   yyin = fopen(fname,"r");
   if (yyin == NULL) {
     lexerr("cannot open include file");
     exit(1);
   }
}
