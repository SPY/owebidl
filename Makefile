all: parser lexer binary

lexer:
	cd src && \
	ocamllex lexer.mll && \
	ocamlc -c lexer.ml

ast:
	ocamlfind ocamlc -syntax camlp4o -package sexplib.syntax -c -w -30 src/ast.ml

$PARSER_GENERATOR=menhir --infer --trace --error-recovery

parser: ast
	cd src && \
	$($PARSER_GENERATOR) -v parser.mly && \
	ocamlc -c parser.mli && \
	ocamlc -c parser.ml

binary:
	cd src && \
	ocamlfind ocamlc -package sexplib -c webidl.ml && \
	ocamlfind ocamlc -package sexplib -linkpkg -o ../bin/webidl ast.cmo lexer.cmo parser.cmo webidl.cmo

run:
	./bin/webidl
