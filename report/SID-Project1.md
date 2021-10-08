# CS323 Project1

###  Lexical Analysis & Syntax Analysis

##### **Team Members: Li Yuanzhao(11812420), Xu Xinyu(11811536), Jiang Yuchen(11812419)**



## I. Overview

​		In this project, we are required to implement lexical analysis and syntax analysis with lexer, syntaxer and other useful files in order to output a parser tree or possible lexical and syntax error information for given SPL(Sustech Programming Language) code. Our files can be run successfully with GCC version 7.4.0, GNU Flex version 2.6.4 and GNU Bison version 3.0.4 .



## II. Design and Implementation

### 	A. Lexer

​			In lexer part, we define a new class named `Node` which record the information of matched token for syntax analysis and final output.

```C++
enum class Node_TYPE{
    INT,
    FLOAT,
    CHAR,
    NAME,   //IF ELSE ASSIGN etc
    ID,     //ALL IDENTIFIERS
    DTYPE,  //DATATYPE, INCLUDING INT,FLOAT & CHAR
    LINE
};

class Node{
private:
    string name;
    //string id_name;// == string_value
    Node_TYPE TYPE;
    union{
        int lineno;
        int int_value;
        float float_value;
        char char_value;
    };
    vector <Node*> sub_nodes;

public:
    Node();

    void print(int space);

    Node(int val);
    Node(float val);
    Node(char val);
    
    Node(string name);
    Node(string name,Node_TYPE type);
    Node(string name,int line_no);

    void set_child(vector<Node*> sub);

};
```

​				We define the variable `has_err`  to record whether there exists possible lexical and syntax error for final output. We also support single line comment symbol `//` besides given matching rules.

<img src="SID-Project1.assets/image-20211008153933364.png" alt="image-20211008153933364" style="zoom:50%;" />

​															Figure.1 Some matching rules we defined in `lex.l`

### 	B. Syntaxer

​			As mentioned in Appendix B, we construct our syntaxer which will accept tokens and make actions or report errors. In this part we will take use of class `Node` not only for tokens' information but also for level differentiation. Finally the nodes will form up  a tree to record those tokens' information when the program has no lexical and syntax error.

​				// Figure

​															Figure.2 Syntax Design

### 	C. Other useful files



## III. Test Cases

​			For evaluation purpose, our test cases contain at least 2 type A errors and 2 type B errors.

## IV. Instructions

​		