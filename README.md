# Compilers_HW_1
First homework assignment for UIdaho's Fall '17 CS445-Compilers class


=====================================================================

### CS 445 Assignment 1: A Lexical Analyzer

*Due: Thursday September 7, 11:30pm*
In this assignment you will write a lexical analyzer in flex(1), for a subset of C++ known as the "120++" language. For this homework, you should write a lexical analyzer for 120++.

Your program executable should be named "120++". Your program should read in any number of source files named on the command line and write output with one line for each token, described below. Compilers and related tools tend to get used by programs such as "make" that read the process exit status to tell whether all is well. Your program's exit status should return 0 if there are no errors, and a nonzero number to indicate errors. For lexical errors, return 1.

### Language Details

ANSI C and thence from K&R C. You may use as a starting point this lex file and corresponding header ytab.h that I happen to have lying about from an old research project. It probably recognizes classic ANSI C. You should (a) figure out how to make this thing compile and run OK for you, (b) fix any bugs, (c) extend with additions in the 120++ specification and this draft ISO C++ 14 document, and (d) modify with any changes needed to comply with the rest of this homework specification. In the event of conflicts, this homework page (hw1.html) takes precedence, followed by the 120++ specification, followed by the C++ 14 specification; they all supercede whatever you happen to find in the sample code.

### Lexical Attributes

In your yylex(), compute attributes for each token, and store them in a global variable named yytoken. Note that this is not part of the lex/yacc public interface, although it is named so as to be a recognizable extension of said interface. You should use the following token type, or a compatible extension of it.
```
struct token {
   int category;   /* the integer code returned by yylex */
   char *text;     /* the actual string (lexeme) matched */
   int lineno;     /* the line number on which the token occurs */
   char *filename; /* the source file in which the token occurs */
   int ival;       /* if you had an integer constant, store its value here */
   int *sval;      /* if you had a string constant, malloc space and store */
   }               /*    the string (less quotes and after escapes) here */
```
In this homework your main() procedure should build a LINK LIST of all the token structs, each of which is created by yylex(). In the next assignment, we will insert all these tokens in a giant (syntax) tree.

Example linked list structure:

```
struct tokenlist {
      struct token *t;
      struct tokenlist *next;
      }
```
Use the malloc() function to allocate chunks of memory for structs token and tokenlist.

### yylex() and main()

Your yylex() should return a different unique integer > 257 for each reserved word, and for each other token category (identifier, integer literal constant, string literal constant, addition operator, etc). Numbers > 257 are required for the sake of compatibility with the YACC parser generator tool. For each such number, you must #define a symbol, as in
\#define IDENTIFIER 260
This is required for the sake of readability. Your yylex() should return -1 when it hits end of file.
In this assignment, there should be (at least) two separately-compiled .c files, a .h file and a makefile. The yylex() function will be called by a main() procedure in a loop. The main() procedure should for each token, write out a line containing the token category (an integer > 257) and lexical attributes.

### Turn in...

Both a paper copy to Dr. J in class, and an electronic copy via bblearn.uidaho.edu. The electronic copy should be a compressed archive .zip file, containing makefile, flex clex.l file, main.c file, and ytab.h file. If you add any new source files, be sure you add it to the set of files that you turn in.

### Example

For the input file

```
int main()
{
   printf("Hello, world\n");
   return 0;
}```
your output should look something like:

```
Category	Text		Lineno		Filename	Ival/Sval
=============================================================
262		int		1		hello.c
271		main		1		hello.c
290		(		1		hello.c
291		)		1		hello.c
292		{		2		hello.c
271		printf		3		hello.c
290		(		3		hello.c
271		"Hello, world\n"3		hello.c		Hello, world

291		)		3		hello.c
263		;		3		hello.c
264		return		4		hello.c
271		0		4		hello.c		0
263		;		4		hello.c
293		}		5		hello.c```

### Include Files?

Unsurprisingly, the lexical analyzer whose job is to read characters may well have to concern itself with how we are going to handle C++ preprocessor directives. What you have heard up to now is that 120++ really would like to not deal with a C++ preprocessor at all, for the sake of simplicity, but even the smallest of newbie toy CS120 programs uses #includes.
Two options present themselves; feel free to suggest additional alternatives and I will be happy to assess their feasibility and acceptibility for our purposes.

Option 0: write an ANSI C/C++ preprocessor, because hey, it would be fun. I wrote one once, and it was fun, but it took too long. Not recommended.
Option 1: invoke the real C++ preprocessor on our input before we ever see it. This is surprisingly easy; using popen() one can just assign yyin to read the input from an external C++ preprocessor invoked on our file. But, then our compiler would have to deal with all the junk in the real system include files, which are enormous and ugly and may include non-standard stuff and therefore pose portability problems. Not recommended.
Option 2: hardwire a recognizer for the allowed system files, where the lexical analyzer recognizes big regular expressions for each system include and just sets a global variable if it is seen. Then handle the user-defined #includes such as "robots.h" directly within the scanner, by saving the current yyin file, opening a new one, and reading from it until it is finished, and then restoring the saved yyin file.
As mentioned, the restrictions on user includes that are acceptable for 120++ are:
user includes are recognizable by surrounding the filename with double-quoets
in 120++, no such include file ever has a directory/path, it is OK to allow only files in the current directory.
in 120++, such include files can include another include file, but the include stack is at most two include files deep.
