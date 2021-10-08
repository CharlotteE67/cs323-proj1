#include "syntax.tab.c"
#include <stdio.h>

int main(int argc,char **argv){
    //from lab2 sample
    char *file_path;
    if(argc < 2){
        fprintf(LEX_ERR_OP, "Usage: %s <file_path>\n", argv[0]);
        return EXIT_FAIL;
    } else if(argc == 2){
        file_path = argv[1];
        if(!(yyin = fopen(file_path, "r"))){
            perror(argv[1]);
            return EXIT_FAIL;
        }
        yylex();
        return EXIT_OK;
    } else{
        fputs("Too many arguments! Expected: 2.\n", LEX_ERR_OP);
        return EXIT_FAIL;
    }
}