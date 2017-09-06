

// #ifndef _MYHEADER_H_INCLUDED // is myheader.h already included?
// #define _MYHEADER_H_INCLUDED
#include <string.h>


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





