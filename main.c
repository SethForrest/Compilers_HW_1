

#include "token.c"

int main(int argc, char* argv[]){
	extern FILE *yyin;
	
	static char *file_name;
	
	// printf("\n\n\nCategory \t Text \t LineNo \t FileName \t Ival/Sval\n");
	// printf("---------------------------------------------------------------------\n");
	
	int i = 1;	argc--; // ignore program name
	
	while(argc-- > 0){
		file_name = argv[i];
		yyin = fopen(file_name, "r");
		yylex();
		
		// printf("arg:%i \targv:%s \n", i, file_name);
		
		fclose(yyin);
		i++;
	}
  return 0;
}







