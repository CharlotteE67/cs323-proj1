#include "spl_node.h"

using namespace std;

void Node::print(int space){
    //printspace
    switch(this->TYPE){
        case Node_TYPE::INT:{
            printf("INT:%d\n",this->int_value);
            break;
        }
        case Node_TYPE::FLOAT:{
            printf("FLOAT:%f\n",this->float_value);
            break;
        }
        case Node_TYPE::CHAR:{
            printf("CHAR:%c\n",this->char_value);
            break;
        }
        case Node_TYPE::NAME:{
            printf("%s\n",this->name.c_str());
            break;
        }
        case Node_TYPE::ID:{
            printf("ID:%s\n",this->name.c_str());
            break;
        }
        case Node_TYPE::DTYPE:{
            printf("TYPE:%s\n",this->name.c_str());
            break;
        }
        case Node_TYPE::LINE:{
            //printline
            break;
        }
    }
}

Node::Node(string name){
    this->name = name;
    this->TYPE = Node_TYPE::NAME;
}

Node::Node(int val){
    this->int_value = val;
    this->TYPE = Node_TYPE::INT;
}
Node::Node(float val){
    this->float_value = val;
    this->TYPE = Node_TYPE::FLOAT;
}
Node::Node(char val){
    this->char_value = val;
    this->TYPE = Node_TYPE::CHAR;
}

Node::Node(string name,Node_TYPE type){
    this->name = name;
    this->TYPE = type;
}

Node::Node(string name,int line_no){
    this->name = name;
    this->lineno = line_no;
    this->TYPE = Node_TYPE::LINE;
}

void Node::set_child(vector<Node*> sub){
    this->sub_nodes = sub;
}