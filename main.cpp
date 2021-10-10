#include "syntax.tab.c"
#include <stdio.h>

#define DEBUG false

int main(int argc,char **argv){
    //from lab2 sample
    if(argc <= 1){
        fprintf(LEX_ERR_OP, "Usage: %s <file_path>\n", argv[0]);
        return EXIT_FAIL;
    } else if(argc == 2){
        FILE *f = fopen(argv[1], "r");
        if(!f){
            fprintf(LEX_ERR_OP, "Can't open the file %s\n", argv[1]);
            return EXIT_FAIL;
        }
        yyrestart(f);
        yyparse();
    } else{
        fprintf(LEX_ERR_OP, "Too many arguments! Expected: 2. Received %d\n", argc);
        return EXIT_FAIL;
    }
    if (!has_err || DEBUG) {
        root->show(0);
    }
    return EXIT_OK;
}