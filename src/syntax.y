%{
    #include "lex.yy.c"

    void yyerror(const char *s);
    void lineinfor(void);
    Node* root;
    extern bool has_err;
%}

%locations
%union{
    Node* value;
}


%nonassoc <value> ELSE
%token <value> TYPE STRUCT
%token <value> ERR_TOKEN
%token <value> IF WHILE RETURN
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
Program:
    ExtDefList { root = $$ = new Node("Program",@$.first_line); vector<Node*> vec = {$1}; $$->set_child(vec); }
;

ExtDefList:
    /* NULL */ { $$ = new Node("ExtDefList", @$.first_line);}
    | ExtDef ExtDefList { $$ = new Node("ExtDefList", @$.first_line); vector<Node*> vec = {$1, $2}; $$->set_child(vec); }
    ;
ExtDef:
    Specifier ExtDecList SEMI { $$ = new Node("ExtDef", @$.first_line); vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
    | Specifier SEMI { $$ = new Node("ExtDef", @$.first_line); vector<Node*> vec = {$1, $2}; $$->set_child(vec);}
    | Specifier FunDec CompSt { $$ = new Node("ExtDef", @$.first_line); vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
    ;
ExtDecList:
    VarDec { $$ = new Node("ExtDecList", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | VarDec COMMA ExtDecList { $$ = new Node("ExtDecList", @$.first_line); vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
;

/* specifier */
Specifier:
    TYPE
    | StructSpecifier
;
StructSpecifier:
    STRUCT ID LC DefList RC
    | STRUCT ID
;

/* declarator */
VarDec:
    ID { $$ = new Node("VarDec", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | VarDec LB INT RB { $$ = new Node("VarDec", @$.first_line); vector<Node*> vec = {$1, $2, $3, $4}; $$->set_child(vec); }
;
FunDec:
    ID LP VarList RP { $$ = new Node("FunDec", @$.first_line); vector<Node*> vec = {$1, $2, $3, $4}; $$->set_child(vec); }
    | ID LP RP { $$ = new Node("FunDec", @$.first_line); vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
;
VarList:
    ParamDec COMMA VarList { $$ = new Node("VarList", @$.first_line); vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
    | ParamDec { $$ = new Node("VarList", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
;
ParamDec:
    Specifier VarDec { $$ = new Node("ParamDec", @$.first_line); vector<Node*> vec = {$1, $2}; $$->set_child(vec); }
;
/* statement */
CompSt:
    LC DefList StmtList RC { $$ = new Node("CompSt", @$.first_line); vector<Node*> vec = {$1, $2, $3, $4}; $$->set_child(vec); }
;
StmtList:
    /* NULL */ { $$ = new Node("StmtList", @$.first_line);}
    | Stmt StmtList { $$ = new Node("StmtList", @$.first_line); vector<Node*> vec = {$1, $2}; $$->set_child(vec); }
;
Stmt:
    Exp SEMI { $$ = new Node("Stmt", @$.first_line); vector<Node*> vec = {$1, $2}; $$->set_child(vec); }
    | CompSt { $$ = new Node("Stmt", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | RETURN Exp SEMI  { $$ = new Node("Stmt", @$.first_line); vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
    | IF LP Exp RP Stmt { $$ = new Node("Stmt", @$.first_line); vector<Node*> vec = {$1, $2, $3, $4, $5}; $$->set_child(vec); }
    | IF LP Exp RP Stmt ELSE Stmt { $$ = new Node("Stmt", @$.first_line); vector<Node*> vec = {$1, $2, $3, $4, $5,  $6, $7}; $$->set_child(vec); }
    | WHILE LP Exp RP Stmt { $$ = new Node("Stmt", @$.first_line); vector<Node*> vec = {$1, $2, $3, $4, $5}; $$->set_child(vec); }
;

/* local definition */
DefList:
    /* NULL */ { $$ = new Node("DefList", @$.first_line);}
    | Def DefList { $$ = new Node("DefList", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
;
Def:
    Specifier DecList SEMI { $$ = new Node("Def", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
;
DecList:
    Dec { $$ = new Node("DecList", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Dec COMMA DecList { $$ = new Node("DecList", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
;
Dec:
    VarDec { $$ = new Node("Dec", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | VarDec ASSIGN Exp { $$ = new Node("Dec", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
;

/* expression */
Exp:
    Exp ASSIGN Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp AND Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp OR Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp LT Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp LE Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp GT Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp GE Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp NE Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp EQ Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp PLUS Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp MINUS Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp MUL Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp DIV Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | LP Exp RP { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | MINUS Exp %prec UMINUS { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | NOT Exp { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | ID LP Args RP { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | ID LP RP { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp LB Exp RB { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
    | Exp DOT ID { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1, $2, $3}; $$->set_child(vec); }
    | ID { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | INT { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | FLOAT { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | CHAR { $$ = new Node("Exp", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
;
Args:
    Exp COMMA Args { $$ = new Node("Args", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
    | Exp { $$ = new Node("Args", @$.first_line);vector<Node*> vec = {$1}; $$->set_child(vec); }
;
%%
void yyerror(const char *s){
    has_err=1;
    fprintf(SYNTAX_ERR_OP,"Error type B at Line %d: ",yylloc.first_line-1);
}

void lineinfor(void){
    fprintf(SYNTAX_ERR_OP, "begin at:(%d,%d)\n",yylloc.first_line,yylloc.first_column);
    fprintf(SYNTAX_ERR_OP, "end at:(%d,%d)\n",yylloc.last_line,yylloc.last_column);
}
