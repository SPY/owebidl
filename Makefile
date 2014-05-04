all: lexer parser binary

lexer:
	cd src && \
	ocamllex lexer.mll && \
	ocamlc -c lexer.ml

ast:
	ocamlc -c -w -30 src/ast.ml

parser: ast
	cd src && \
	ocamlyacc -v parser.mly && \
	ocamlc -c parser.mli && \
	ocamlc -c parser.ml

binary:
	cd src && \
	ocamlc -c webidl.ml && \
	ocamlc -o ../bin/webidl lexer.cmo parser.cmo webidl.cmo

run:
	OCAMLRUNPARAM='p' ./bin/webidl
