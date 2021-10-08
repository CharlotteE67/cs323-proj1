#include "spl_node.hpp"

using namespace std;

void Node::print(int depth) {
    if (child.empty() && TYPE == Node_TYPE::LINE)
        return;

    while (depth--)
        printf("  ");

    switch (TYPE) {
        case Node_TYPE::INT: {
            printf("INT: %d\n", int_value);
            break;
        }
        case Node_TYPE::FLOAT: {
            printf("FLOAT: %f\n", float_value);
            break;
        }
        case Node_TYPE::CHAR: {
            printf("CHAR: %c\n", char_value);
            break;
        }
        case Node_TYPE::NAME: {
            printf("%s\n", name.c_str());
            break;
        }
        case Node_TYPE::ID: {
            printf("ID: %s\n", name.c_str());
            break;
        }
        case Node_TYPE::DTYPE: {
            printf("TYPE: %s\n", name.c_str());
            break;
        }
        case Node_TYPE::LINE: {
            printf("%s (%d)\n", name.c_str(), lineno);
            break;
        }
    }
}

Node::Node(string name) {
    this->name = name;
    this->TYPE = Node_TYPE::NAME;
}

Node::Node(int val) {
    this->int_value = val;
    this->TYPE = Node_TYPE::INT;
}

Node::Node(float val) {
    this->float_value = val;
    this->TYPE = Node_TYPE::FLOAT;
}

Node::Node(char val) {
    this->char_value = val;
    this->TYPE = Node_TYPE::CHAR;
}

Node::Node(string name, Node_TYPE type) {
    this->name = name;
    this->TYPE = type;
}

Node::Node(string name, int line_no) {
    this->name = name;
    this->lineno = line_no;
    this->TYPE = Node_TYPE::LINE;
}

Node::Node(string name, int line_no, vector<Node *> &child) {
    this->name = name;
    this->lineno = line_no;
    this->TYPE = Node_TYPE::LINE;
    this->child = child;
}

void Node::set_child(vector<Node *> &child) {
    this->child = child;
}

void Node::show(int depth) {
    print(depth);
    for (auto it: child) {
        it->show(depth + 1);
    }
}