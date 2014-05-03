all: lexer parser

lexer:
	cd src && \
	ocamllex lexer.mll && \
	ocamlc -c lexer.ml

ast:
	ocamlc -c -w -30 src/ast.ml

parser: ast
	cd src && \
	ocamlyacc parser.mly && \
	ocamlc -c parser.mli && \
	ocamlc -c parser.ml
