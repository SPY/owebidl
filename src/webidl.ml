let _ =
  let fragment = "interface Foo : Bar { };" in
  let lexbuf = Lexing.from_string fragment in
  try
    let result = Parser.definitions Lexer.token lexbuf in
    print_string "success parsing\n";
  with exn ->
    begin
      let open Lexing in
      let curr = lexbuf.lex_curr_p in
      let line = curr.pos_lnum in
      let cnum = curr.pos_cnum - curr.pos_bol in
      let token = lexeme lexbuf in
      Printf.printf "fail at line %d at position %d on token %s\n" line cnum token
    end
