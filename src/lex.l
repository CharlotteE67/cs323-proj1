%{
    #include "syntax.tab.h"
    #include "stdlib.h"

    #define EXIT_OK 0
    #define EXIT_FAIL 1
%}
%option yylineno

num [0-9]
num_16 [0-9a-fA-F]
letter [a-zA-Z]
letter_ [a-zA-Z_]

INT_10 ([1-9]{num}*)|0
INT_16 0[xX](0|[1-9A-Fa-f]{num_16}*)
FLOAT {num}+\.{num}+
CHAR '.'
CHAR_16 '\\x(0|[1-9a-fA-F]{num_16})'
ID {letter_}({letter_}|{num}){0,31}


%%
"//" { char c = yyinput();while(c!='\n'){c=yyinput();}}
"int"|"float"|"char" { return TYPE; }
"struct" { return STRUCT; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"return" { return RETURN; }
"." { return DOT; }
";" { return SEMI; }
"," { return COMMA; }
"=" { return ASSIGN; }
"<" { return LT; }
"<=" { return LE; }
">" { return GT; }
">=" { return GE; }
"!=" { return NE; }
"==" { return EQ; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MUL; }
"/" { return DIV; }
"&&" { return AND; }
"||" { return OR; }
"!" { return NOT; }
"(" { return LP; }
")" { return RP; }
"[" { return LB; }
"]" { return RB; }
"{" { return LC; }
"}" { return RC; }
[ \n\r\t]+ {}

{ID} {return ID;}
{INT_10} {return INT;}
{INT_16} {return INT;}
{FLOAT} {return FLOAT;}
{CHAR} {return CHAR;}
{CHAR_16} {return CHAR;} 




. { fprintf(stderr, "unknown symbol: %s\n", yytext); exit(1); }
%%

int main(int argc,char **argv){
    //from lab2 sample
    char *file_path;
    if(argc < 2){
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
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
        fputs("Too many arguments! Expected: 2.\n", stderr);
        return EXIT_FAIL;
    }
}