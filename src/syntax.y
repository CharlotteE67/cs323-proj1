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
    Node* value;
}

%token <value> INT FLOAT CHAR
%token <value> ID
%right <value> ASSIGN
%left <value> OR
%left <value> AND
%left <value> LT LE GT GE NE EQ
%left <value> PLUS MINUS
%left <value> MUL DIV
%left UMINUS
%right <value> NOT
%left <value> LP RP LB RB DOT
%token <value> SEMI COMMA
%token <value> LC RC

%type <value> Program ExtDefList
%type <value> ExtDef ExtDecList Specifier StructSpecifier VarDec
%type <value> FunDec VarList ParamDec CompSt StmtList Stmt DefList
%type <value> Def DecList Dec Args Exp
%%
/* high-level definition */
Program: ExitDefList

ExtDefList:
    /* NULL */
    | ExtDef ExtDefList
    ;
ExtDef:
    Specifier ExtDecList SEMI
    | Specifier SEMI
    | Specifier FuncDec CompSt
    ;
ExtDecList:
    VarDec
    | VarDec COMMMA ExtDecList
;
/* declarator */
VarDec:
    ID
    | VarDec LB INT RB
;
FunDec:
    ID LP VarList RP
    | ID LP RP
;
VarList:
    ParamDec COMMA VarList
    | ParamDec
;
ParamDec:
    Specifier VarDec
;
/* statement */
CompSt:
    LC DefList StmtList RC
;
StmtList:
    /* NULL */
    | Stmt StmtList
;
Stmt:
    Ecp SEMI
    | CompSt
    | RETURN Exp SEMI
    | IF LP Exp RP Stmt
    | IF LP Exp RP Stmt ELSE Stmt
    | WHILE LP Exp RP Stmt
;

/* local definition */
DefList:
    /* NULL */
    | Def DefList
;
Def:
    Specifier DecList SEMI
;
DecList:
    Dec
    | Dec COMMA DecList
;
Dec:
    VarDec
    | VarDec ASSIGN Exp
;

/* expression */
Exp:
    Exp ASSIGN Exp
    | Exp AND Exp
    | Exp OR Exp
    | Exp LT Exp
    | Exp LE Exp
    | Exp GT Exp
    | Exp GE Exp
    | Exp NE Exp
    | Exp EQ Exp
    | Exp PLUS Exp
    | Exp MINUS Exp
    | Exp MUL Exp
    | Exp DIV Exp
    | LP Exp RP
    | MINUS Exp %prec UMINUS
    | NOT Exp
    | ID LP Args RP
    | ID LP RP
    | Exp LB Exp RB
    | Exp DOT ID
    | ID
    | INT
    | FLOAT
    | CHAR
;
Args: Exp COMMA Args
    | Exp
;
%%
void yyerror(const char *s){
    has_err=1;
    fprintf(stdout,"Error type B at Line %d: ",yylloc.first_line-1);
}

void lineinfor(void){
    fprintf(stderr, "begin at:(%d,%d)\n",yylloc.first_line,yylloc.first_column);
    fprintf(stderr, "end at:(%d,%d)\n",yylloc.last_line,yylloc.last_column);
}
