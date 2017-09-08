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



"alignas"									{ tokenize(ALIGNAS);	 return ALIGNAS; }
"alignof"									{ tokenize(ALIGNOF);	 return ALIGNOF; }
"and_eq"									{ tokenize(AND_EQ);	 return AND_EQ; }
"asm"											{ tokenize(ASM);	 return ASM; }
"atomic_cancel"						{ tokenize(ATOMIC_CANCEL);	 return ATOMIC_CANCEL; }
"atomic_commit"						{ tokenize(ATOMIC_COMMIT);	 return ATOMIC_COMMIT; }
"atomic_noexcept"		{ tokenize(ATOMIC_NOEXCEPT);	 return ATOMIC_NOEXCEPT; }
"bitand"		{ tokenize(BITAND);	 return BITAND; }
"bitor"		{ tokenize(BITOR);	 return BITOR; }
"bool"		{ tokenize(BOOL);	 return BOOL; }
"catch"		{ tokenize(CATCH);	 return CATCH; }
"char16_t"		{ tokenize(CHAR16_T);	 return CHAR16_T; }
"char32_t"		{ tokenize(CHAR32_T);	 return CHAR32_T; }
"class"		{ tokenize(CLASS);	 return CLASS; }
"compl"		{ tokenize(COMPL);	 return COMPL; }
"concept"		{ tokenize(CONCEPT);	 return CONCEPT; }
"constexpr"		{ tokenize(CONSTEXPR);	 return CONSTEXPR; }
"const_cast"		{ tokenize(CONST_CAST);	 return CONST_CAST; }
"decltype"		{ tokenize(DECLTYPE);	 return DECLTYPE; }
"delete"		{ tokenize(DELETE);	 return DELETE; }
"dynamic_cast"		{ tokenize(DYNAMIC_CAST);	 return DYNAMIC_CAST; }
"explicit"		{ tokenize(EXPLICIT);	 return EXPLICIT; }
"export"		{ tokenize(EXPORT);	 return EXPORT; }
"friend"		{ tokenize(FRIEND);	 return FRIEND; }
"import"		{ tokenize(IMPORT);	 return IMPORT; }
"inline"		{ tokenize(INLINE);	 return INLINE; }
"module"		{ tokenize(MODULE);	 return MODULE; }
"mutable"		{ tokenize(MUTABLE);	 return MUTABLE; }
"namespace"		{ tokenize(NAMESPACE);	 return NAMESPACE; }
"new"		{ tokenize(NEW);	 return NEW; }
"noexcept"		{ tokenize(NOEXCEPT);	 return NOEXCEPT; }
"not_eq"		{ tokenize(NOT_EQ);	 return NOT_EQ; }
"nullptr"		{ tokenize(NULLPTR);	 return NULLPTR; }
"operator"		{ tokenize(OPERATOR);	 return OPERATOR; }
"or_eq"		{ tokenize(OR_EQ);	 return OR_EQ; }
"private"		{ tokenize(PRIVATE);	 return PRIVATE; }
"protected"		{ tokenize(PROTECTED);	 return PROTECTED; }
"public"		{ tokenize(PUBLIC);	 return PUBLIC; }
"reinterpret_cast"		{ tokenize(REINTERPRET_CAST);	 return REINTERPRET_CAST; }
"requires"		{ tokenize(REQUIRES);	 return REQUIRES; }
"static_assert"		{ tokenize(STATIC_ASSERT);	 return STATIC_ASSERT; }
"static_cast"		{ tokenize(STATIC_CAST);	 return STATIC_CAST; }
"synchronized"		{ tokenize(SYNCHRONIZED);	 return SYNCHRONIZED; }
"template"		{ tokenize(TEMPLATE);	 return TEMPLATE; }
"this"		{ tokenize(THIS);	 return THIS; }
"thread_local"		{ tokenize(THREAD_LOCAL);	 return THREAD_LOCAL; }
"throw"		{ tokenize(THROW);	 return THROW; }
"try"		{ tokenize(TRY);	 return TRY; }
"typeid"		{ tokenize(TYPEID);	 return TYPEID; }
"typename"		{ tokenize(TYPENAME);	 return TYPENAME; }
"using"		{ tokenize(USING);	 return USING; }
"virtual"		{ tokenize(VIRTUAL);	 return VIRTUAL; }
"wchar_t"		{ tokenize(WCHAR_T);	 return WCHAR_T; }
"xor"		{ tokenize(XOR);	 return XOR; }
"xor_eq"		{ tokenize(XOR_EQ);	 return XOR_EQ; }


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
