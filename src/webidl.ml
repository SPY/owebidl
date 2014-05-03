let _ =
  let fragment = "interface Foo: Bar { }" in
  let lexbuf = Lexing.from_string fragment in
  let result = Parser.definitions Lexer.token lexbuf in
  print_string "success parsing"; print_newline(); flush stdout
