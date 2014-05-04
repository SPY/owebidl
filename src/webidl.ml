module Sexp = Sexplib.Sexp

let _ =
  let lexbuf = Lexing.from_channel (open_in "tests/simpl.idl") in
  try
    let result = Parser.definitions Lexer.token lexbuf in
    let str = Sexp.to_string (Ast.sexp_of_definitions result) in
    print_endline str
  with exn ->
    begin
      let open Lexing in
      let curr = lexbuf.lex_curr_p in
      let line = curr.pos_lnum in
      let cnum = curr.pos_cnum - curr.pos_bol in
      let token = lexeme lexbuf in
      Printf.printf "fail at line %d at position %d on token %s\n" line cnum token
    end
