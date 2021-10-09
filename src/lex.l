%{
    #include "spl_node.hpp"
    bool has_err = false;
    #define LEX_ERR_OP stdout
    #define SYNTAX_ERR_OP stdout
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

%option noyywrap
%option yylineno

num [0-9]
num_16 [0-9a-fA-F]
letter [a-zA-Z]
letter_ [a-zA-Z_]

INT_10 0|([1-3]{num}{0,9})|([4-9]{num}{0,8})|(4[01]{num}{8})|(42[0-8]{num}{7})|(429[0-3]{num}{6})|(4294[0-8]{num}{5})|(42949[0-5]{num}{4})|(429496[0-6]{num}{3})|(4294967[01]{num}{2})|(42949672[0-8]{num})|(429496729[0-5])
INT_16 0[xX](0|[1-9A-Fa-f]{num_16}{0,7})
FLOAT {num}+\.{num}+
CHAR '.'
CHAR_16 '\\x(0|[1-9a-fA-F]{num_16})'
ID {letter_}({letter_}|{num}){0,31}

ID_ERR_TOOLONG {letter_}({letter_}|{num}){32,}
ID_ERR_NUMSTA {num}({letter_}|{num}){0,31}

INT_10_ERR_OUTRANGE [1-9]{num}+
INT_10_ERR_0STA 0{num}+
INT_10_ERR_CHARILL {num}*([^0-9]+{num}*)*

CHAR_ERR_TOOLONG '.{2,}'

INT_16_ERR_CHARILL 0[xX](({num_16}*[^0-9a-fA-F]+)+{num_16}*)
INT_16_ERR_MORE0 0[xX](0+{num_16}+)
INT_16_ERR_TOOLONG 0[xX](.{9,})

CHAR_16_ERR_TOOLONG '\\x.{3,}'
CHAR_16_ERR_CHARILL '\\x{num_16}*[^0-9a-fA-F]+{num_16}*'
CHAR_16_ERR_MORE0 '\\x0+{num_16}'



%%
"//" { char c = yyinput();while(c!='\n'){c=yyinput();}}

"\n" {yycolumn = 1;}
"int" { 
    yylval.value = new Node("int",Node_TYPE::DTYPE);
    return TYPE; 
}
"float" { 
    yylval.value = new Node("float",Node_TYPE::DTYPE);
    return TYPE; 
}
"char" { 
    yylval.value = new Node("char",Node_TYPE::DTYPE);
    return TYPE; 
}
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
[ \r\t]+ {}

{ID} {
    yylval.value = new Node(yytext,Node_TYPE::ID);
    return ID;
}
{INT_10} {
    yylval.value = new Node(atoi(yytext));
    return INT;
}
{INT_16} {
    yylval.value = new Node(static_cast<int>(strtol(yytext,nullptr,0)));
    return INT;
}
{FLOAT} {
    yylval.value = new Node(static_cast<float>(atof(yytext)));
    return FLOAT;
}
{CHAR} {
    yylval.value = new Node(yytext,Node_TYPE::CHAR);
    return CHAR;
}
{CHAR_16} {
    yylval.value = new Node(yytext,Node_TYPE::CHAR);
    return CHAR;
} 

{ID_ERR_NUMSTA} {
    has_error = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: identifier starts with number \n",yylineno);
    return ERR_TOKEN;
}

{ID_ERR_TOOLONG} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: identifier too long\n",yylineno);
    return ERR_TOKEN;
}


{INT_10_ERR_0STA} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: number start with 0\n",yylineno);
    return ERR_TOKEN;
}
{INT_10_ERR_OUTRANGE} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: int number overflow \n",yylineno);
    return ERR_TOKEN;

}
{INT_10_ERR_CHARILL} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: int number with illegal char \n",yylineno);
    return ERR_TOKEN;
}


{CHAR_ERR_TOOLONG} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: too many chars\n",yylineno);
    return ERR_TOKEN;
}


{INT_16_ERR_TOOLONG} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: int number overflow \n",yylineno);
    return ERR_TOKEN;
}
{INT_16_ERR_CHARILL} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: hexadecimal int with illegal char\n",yylineno);
    return ERR_TOKEN;
}
{INT_16_ERR_MORE0} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: too many 0 at the beginning of hexadecimal representation \n",yylineno);
    return ERR_TOKEN;
}


{CHAR_16_ERROR_TOOLONG} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: hexadecimal representation too long \n",yylineno);
    return ERR_TOKEN;
}
{CHAR_16_ERR_CHARILL} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: hexadecimal representation with illegal char\n",yylineno);
    return ERR_TOKEN;
}
{CHAR_16_ERR_MORE0} {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: too many 0 at the beginning of hexadecimal representation\n",yylineno);
    return ERR_TOKEN;
}




. {
    has_err = 1;
    fprintf(LEX_ERR_OP,"Error type A at Line %d: unknown lexeme %s\n",yylineno, yytext);
    return ERR_TOKEN;
}
%%
