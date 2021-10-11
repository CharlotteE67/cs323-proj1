%{
    #include "lex.yy.c"

    void yyerror(const char *s);
    void lineinfor(void);
    Node* root;
    extern bool has_err;
    
    
    const string
            ERR_NO_LP = "Missing left parenthesis \'(\'" ,
            ERR_NO_RP = "Missing right parenthesis \')\'" ,
            ERR_NO_LB = "Missing left bracket \'[\'" ,
            ERR_NO_RB = "Missing right bracket \']\'" ,
            ERR_NO_LC = "Missing left curly braces \'{\'" ,
            ERR_NO_RC = "Missing right curly braces \'}\'" ,
            ERR_NO_SPEC = "Missing specifier" ,
            ERR_NO_SEMI = "Missing semicolon \';\'" ,
            ERR_NO_COMMA = "Missing comma \',\'" ,
            ERR_MORE_COMMA = "Unexpected comma \',\'" ;
%}

%locations
%union{
    Node* value;
}

%nonassoc LACK_ERR
%nonassoc <value> ERR_TOKEN
%nonassoc <value> NELSE
%nonassoc <value> ELSE
%token <value> TYPE STRUCT
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
    ExtDefList { vector<Node*> vec = {$1}; root = $$ = new Node("Program", @$.first_line, vec); }
;

ExtDefList:
    /* NULL */ { $$ = new Node("ExtDefList", @$.first_line);}
    | ExtDef ExtDefList { vector<Node*> vec = {$1, $2}; $$ = new Node("ExtDefList", @$.first_line, vec); }
    ;
ExtDef:
    Specifier ExtDecList SEMI { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("ExtDef", @$.first_line, vec); }
    | Specifier SEMI { vector<Node*> vec = {$1, $2}; $$ = new Node("ExtDef", @$.first_line, vec); $$->set_child(vec);}
    | Specifier FunDec CompSt { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("ExtDef", @$.first_line, vec); }
    | Specifier ExtDecList error  {puts(ERR_NO_SEMI.c_str());}
    | Specifier error {puts(ERR_NO_SEMI.c_str());}
    ;
ExtDecList:
    VarDec { vector<Node*> vec = {$1}; $$ = new Node("ExtDecList", @$.first_line, vec); }
    | VarDec COMMA ExtDecList { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("ExtDecList", @$.first_line, vec); }
    | VarDec ExtDecList error {puts(ERR_NO_COMMA.c_str());}
;

/* specifier */
Specifier:
    TYPE { vector<Node*> vec = {$1}; $$ = new Node("Specifier", @$.first_line, vec); }
    | StructSpecifier { vector<Node*> vec = {$1}; $$ = new Node("Specifier", @$.first_line, vec); }
;
StructSpecifier:
    STRUCT ID LC DefList RC { vector<Node*> vec = {$1, $2, $3, $4, $5}; $$ = new Node("StructSpecifier", @$.first_line, vec); }
    | STRUCT ID { vector<Node*> vec = {$1, $2}; $$ = new Node("StructSpecifier", @$.first_line, vec); }
    | STRUCT ID LC DefList error { puts(ERR_NO_RC.c_str()); }
;

/* declarator */
VarDec:
    ID { vector<Node*> vec = {$1}; $$ = new Node("VarDec", @$.first_line, vec); }
    | VarDec LB INT RB { vector<Node*> vec = {$1, $2, $3, $4}; $$ = new Node("VarDec", @$.first_line, vec); }
    | VarDec LB INT error %prec LACK_ERR {puts(ERR_NO_RB.c_str());}
;
FunDec:
    ID LP VarList RP { vector<Node*> vec = {$1, $2, $3, $4}; $$ = new Node("FunDec", @$.first_line, vec); }
    | ID LP RP { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("FunDec", @$.first_line, vec); }
    | ID LP VarList error {puts(ERR_NO_RP.c_str());}
    | ID LP error {puts(ERR_NO_RP.c_str());}
;
VarList:
    ParamDec COMMA VarList { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("VarList", @$.first_line, vec); }
    | ParamDec { vector<Node*> vec = {$1}; $$ = new Node("VarList", @$.first_line, vec); }
    | ParamDec VarList error {puts(ERR_NO_COMMA.c_str());}
    | ParamDec COMMA error { puts(ERR_MORE_COMMA.c_str()); }
;
ParamDec:
    Specifier VarDec { vector<Node*> vec = {$1, $2}; $$ = new Node("ParamDec", @$.first_line, vec); }
;
/* statement */
CompSt:
    LC DefList StmtList RC { vector<Node*> vec = {$1, $2, $3, $4}; $$ = new Node("CompSt", @$.first_line, vec); }
    | LC DefList StmtList error { puts(ERR_NO_RC.c_str()); }
;
StmtList:
    /* NULL */ { $$ = new Node("StmtList", @$.first_line);}
    | Stmt StmtList { vector<Node*> vec = {$1, $2}; $$ = new Node("StmtList", @$.first_line, vec); }
;
Stmt:
    Exp SEMI { vector<Node*> vec = {$1, $2}; $$ = new Node("Stmt", @$.first_line, vec); }
    | CompSt { vector<Node*> vec = {$1}; $$ = new Node("Stmt", @$.first_line, vec); }
    | RETURN Exp SEMI  { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Stmt", @$.first_line, vec); }
    | IF LP Exp RP Stmt %prec NELSE { vector<Node*> vec = {$1, $2, $3, $4, $5}; $$ = new Node("Stmt", @$.first_line, vec); }
    | IF LP Exp RP Stmt ELSE Stmt { vector<Node*> vec = {$1, $2, $3, $4, $5, $6, $7}; $$ = new Node("Stmt", @$.first_line, vec); }
    | WHILE LP Exp RP Stmt { vector<Node*> vec = {$1, $2, $3, $4, $5}; $$ = new Node("Stmt", @$.first_line, vec); }
    | WHILE LP Exp error Stmt {puts(ERR_NO_RP.c_str()); }
    | Exp error {puts(ERR_NO_SEMI.c_str());}
    | RETURN Exp error {puts(ERR_NO_SEMI.c_str());}
    | IF LP Exp error Stmt  {puts(ERR_NO_RP.c_str()); }
    | IF LP Exp error Stmt ELSE Stmt {puts(ERR_NO_RP.c_str()); }
    | IF error Exp RP Stmt ELSE Stmt{puts(ERR_NO_LP.c_str()); }
;

/* local definition */
DefList:
    /* NULL */ { $$ = new Node("DefList", @$.first_line);}
    | Def DefList { vector<Node*> vec = {$1, $2}; $$ = new Node("DefList", @$.first_line, vec); }
;
Def:
    Specifier DecList SEMI { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Def", @$.first_line, vec); }
    | Specifier DecList error {puts(ERR_NO_SEMI.c_str());}
    | error DecList SEMI {puts(ERR_NO_SPEC.c_str());}
    | Specifier error {puts("No Declare List");}
;
DecList:
    Dec { vector<Node*> vec = {$1}; $$ = new Node("DecList", @$.first_line, vec); }
    | Dec COMMA DecList { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("DecList", @$.first_line, vec); }
    | Dec DecList error {puts(ERR_NO_COMMA.c_str());}
;
Dec:
    VarDec { vector<Node*> vec = {$1}; $$ = new Node("Dec", @$.first_line, vec); }
    | VarDec ASSIGN Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Dec", @$.first_line, vec); }
;

/* expression */
Exp:
    Exp ASSIGN Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp AND Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp OR Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp LT Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp LE Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp GT Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp GE Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp NE Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp EQ Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp PLUS Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp MINUS Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp MUL Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp DIV Exp { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | LP Exp RP { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | NOT Exp { vector<Node*> vec = {$1, $2}; $$ = new Node("Exp", @$.first_line, vec); }
    | ID LP Args RP { vector<Node*> vec = {$1, $2, $3, $4}; $$ = new Node("Exp", @$.first_line, vec); }
    | ID LP RP { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp LB Exp RB { vector<Node*> vec = {$1, $2, $3, $4}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp DOT ID { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Exp", @$.first_line, vec); }
    | ID { vector<Node*> vec = {$1}; $$ = new Node("Exp", @$.first_line, vec); }
    | INT { vector<Node*> vec = {$1}; $$ = new Node("Exp", @$.first_line, vec); }
    | FLOAT { vector<Node*> vec = {$1}; $$ = new Node("Exp", @$.first_line, vec); }
    | LP Exp error {puts(ERR_NO_RP.c_str());}
    | ID LP Args error {puts(ERR_NO_RP.c_str());}
    | ID LP error {puts(ERR_NO_RP.c_str());}
    | CHAR { vector<Node*> vec = {$1}; $$ = new Node("Exp", @$.first_line, vec); }
    | Exp LB Exp error {puts(ERR_NO_RB.c_str());}
    | Exp ERR_TOKEN Exp {}
    | ERR_TOKEN {}
;
Args:
    Exp COMMA Args { vector<Node*> vec = {$1, $2, $3}; $$ = new Node("Args", @$.first_line, vec); }
    | Exp { vector<Node*> vec = {$1}; $$ = new Node("Args", @$.first_line, vec); }
    | Exp COMMA error { puts(ERR_MORE_COMMA.c_str()); }
    | Exp Args error { puts(ERR_NO_COMMA.c_str()); }
;
%%
void yyerror(const char *s){
    has_err = true;
    fprintf(SYNTAX_ERR_OP,"Error type B at Line %d: ",yylloc.first_line-1);
}

void lineinfor(void){
    fprintf(SYNTAX_ERR_OP, "begin at:(%d,%d)\n",yylloc.first_line,yylloc.first_column);
    fprintf(SYNTAX_ERR_OP, "end at:(%d,%d)\n",yylloc.last_line,yylloc.last_column);
}
