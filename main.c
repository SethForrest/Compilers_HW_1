
#include<stdio.h>

int main(int argc, char* argv[]){
	
	printf("\n\n\nCategory \t Text \t LineNo \t FileName \t Ival/Sval\n");
	printf("---------------------------------------------------------------------\n");
	
	int i = 1;	argc--; // ignore program name
	
	while(argc-- > 0){
		printf("arg:%i \targv:%s \n", i, argv[i]);
		i++;
	}
  return 0;
}