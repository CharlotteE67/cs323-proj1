%{
    #include "spl_node.h"
    int isError = 0;
    #define LEXER_ERROR_OUTPUT stdout
%}

%{
    #include "syntax.tab.h"
    #include "stdlib.h"

    #define EXIT_OK 0
    #define EXIT_FAIL 1

    #include"syntax.tab.h"
    /* library inclusions */ 
    int yycolumn = 1;
    #define YY_USER_ACTION \
        yylloc.first_line = yylineno; \
        yylloc.last_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yylloc.last_column = yycolumn + yyleng;\
        yycolumn += yyleng;
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
"\n" {yycolumn = 1;}
"int" { yylval.value = new Node("INT",Node_TYPE::DTYPE);return TYPE; }
"float" { yylval.value = new Node("FLOAT",Node_TYPE::DTYPE);return TYPE; }
"char" { yylval.value = new Node("CHAR",Node_TYPE::DTYPE);return TYPE; }
"struct" { yylval.value = new Node("STRUCT");return STRUCT; }
"if" { yylval.value = new Node("IF");return IF; }
"else" { yylval.value = new Node("ELSE");return ELSE; }
"while" { yylval.value = new Node("WHILE");return WHILE; }
"return" { yylval.value = new Node("RETURN");return RETURN; }
"." { yylval.value = new Node("DOT");return DOT; }
";" { yylval.value = new Node("SEMI");return SEMI; }
"," { yylval.value = new Node("COMMA");return COMMA; }
"=" { yylval.value = new Node("ASSIGN");return ASSIGN; }
"<" { yylval.value = new Node("LT");return LT; }
"<=" { yylval.value = new Node("LE");return LE; }
">" { yylval.value = new Node("GT");return GT; }
">=" { yylval.value = new Node("GE");return GE; }
"!=" { yylval.value = new Node("NE");return NE; }
"==" { yylval.value = new Node("EQ");return EQ; }
"+" { yylval.value = new Node("PLUS");return PLUS; }
"-" { yylval.value = new Node("MINUS");return MINUS; }
"*" { yylval.value = new Node("MUL");return MUL; }
"/" { yylval.value = new Node("DIV");return DIV; }
"&&" { yylval.value = new Node("AND");return AND; }
"||" { yylval.value = new Node("OR");return OR; }
"!" { yylval.value = new Node("NOT");return NOT; }
"(" { yylval.value = new Node("LP");return LP; }
")" { yylval.value = new Node("RP");return RP; }
"[" { yylval.value = new Node("LB");return LB; }
"]" { yylval.value = new Node("RB");return RB; }
"{" { yylval.value = new Node("LC");return LC; }
"}" { yylval.value = new Node("RC");return RC; }
[ \n\r\t]+ {}

{ID} {yylval.value = new Node(yytext,Node_TYPE::ID);return ID;}
{INT_10} {yylval.value = new Node(atoi(yytext));return INT;}
{INT_16} {return INT;}
{FLOAT} {yylval.value = new Node(static_cast<float>(atof(yytext)));return FLOAT;}
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