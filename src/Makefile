GPP=g++
FLEX=flex
BISON=bison
CXX_STD = -std=c++17

CXX_DEBUG = -g -Wall
SRC_PATH=src
CXX_WARN = -Wall -Wextra
MAKE_PATH=./make-build-dir
CXX_FLAGS = -O3 $(CXX_DEBUG) $(CXX_STD) $(CXX_WARN)
CPP = $(GPP) $(CXX_FLAGS)

.PHONY: clean
.lex: lex.l
	$(FLEX) lex.l
.syntax: syntax.y
	$(BISON) -t -d -v syntax.y
.spl_node: .lex .syntax
	$(CPP) -c spl_node.cpp -o spl_node.o
	@ar -rc libspl_node.a spl_node.o
.yyerror: .lex .syntax
	$(CPP) -c yyerror_myself.cpp -o yyerror_myself.o
	@ar -rc libyyerror_myself.a yyerror_myself.o
.parser: .lex .syntax
	$(CPP) -c syntax.tab.c -o parser.o -lfl -ly
	@ar -rc libparser.a parser.o
splc: .spl_node .parser
	$(CPP) main.cpp -static -L. -lspl_node -lparser -o splc
clean:
	@rm -rf $(MAKE_PATH)/ lex.yy.c syntax.tab.* *.out *.o *.a *.so syntax.output splc