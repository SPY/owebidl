all: lexer parser

lexer:
	ocamllex src/lexer.mll
	ocamlc -c src/lexer.ml

ast:
	ocamlc -c src/ast.ml

parser: ast
	cd src && \
	ocamlyacc parser.mly && \
	ocamlc -c parser.mli && \
	ocamlc -c parser.ml
