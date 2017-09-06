


struct token {
	int category;   /* the integer code returned by yylex */
	char *text;     /* the actual string (lexeme) matched */
	int lineno;     /* the line number on which the token occurs */
	char *filename; /* the source file in which the token occurs */
	int ival;       /* if you had an integer constant, store its value here */
	int *sval;      /* if you had a string constant, malloc space and store */
};                /*    the string (less quotes and after escapes) here */

struct tokenlist {
	struct token *t;
	struct tokenlist *next;
};


void create_token(int category);
void print_token(struct token *t);
struct token *make_token(	int category, int lineno, const char *text );