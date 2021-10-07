%{
    #include "lex.yy.c"
    #include "yyerror_myself.hpp"
    void yyerror(const char *s);
    void lineinfor(void);
    Node* root_node;
    extern bool has_err = 0;
%}

%locations
%union{
    Node* Node_value;
}
%nonassoc LOWER_ERROR
%nonassoc <Node_value> ILLEGAL_TOKEN
%nonassoc <Node_value> LOWER_THAN_ELSE
%nonassoc <Node_value> ELSE
%token <Node_value> TYPE STRUCT
%token <Node_value> IF WHILE RETURN
%token <Node_value> INT
%token <Node_value> FLOAT
%token <Node_value> CHAR
%token <Node_value> ID
%right <Node_value> ASSIGN
%left <Node_value> OR
%left <Node_value> AND
%left <Node_value> LT LE GT GE NE EQ
%nonassoc LOWER_MINUS
%left <Node_value> PLUS MINUS
%left <Node_value> MUL DIV
%right <Node_value> NOT
%left <Node_value> LP RP LB RB DOT
%token <Node_value> SEMI COMMA
%token <Node_value> LC RC

%type <Node_value> Program ExtDefList
%type <Node_value> ExtDef ExtDecList Specifier StructSpecifier VarDec
%type <Node_value> FunDec VarList ParamDec CompSt StmtList Stmt DefList
%type <Node_value> Def DecList Dec Args Exp
%%
/* high-level definition */
%%
void yyerror(const char *s){
    has_err=1;
    fprintf(stdout,"Error type B at Line %d: ",yylloc.first_line-1);
}

void lineinfor(void){
    fprintf(stderr, "begin at:(%d,%d)\n",yylloc.first_line,yylloc.first_column);
    fprintf(stderr, "end at:(%d,%d)\n",yylloc.last_line,yylloc.last_column);
}
