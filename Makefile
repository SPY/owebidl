all: lexer parser

lexer:
	ocamllex src/lexer.mll
	ocamlc -c src/lexer.ml

parser:
	ocamlyacc src/parser.mly
	ocamlc -c src/parser.mli
	ocamlc -c src/parser.ml
