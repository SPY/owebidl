

let with_file filename ~f =
  let ic = open_in filename in
  let _ = f ic in
  close_in ic

let out_definitions_count (definitions:Ast.definitions) =
  print_endline ("Definitions amount: " ^ (string_of_int (List.length definitions)))

let parse filename =
  with_file filename ~f:(fun ic ->
    let lexbuf = Lexing.from_channel ic in
    try
      let result = Parser.definitions Lexer.token lexbuf in
      out_definitions_count result;
      (* Generator.generate result *)
      (* let module Sexp = Sexplib.Sexp in
      let str = Sexp.to_string (Ast.sexp_of_definitions result) in
      print_endline str *)
    with exn ->
      begin
	let open Lexing in
	let curr = lexbuf.lex_curr_p in
	let line = curr.pos_lnum in
	let cnum = curr.pos_cnum - curr.pos_bol in
	let token = lexeme lexbuf in
	Printf.printf "fail at line %d at position %d on token %s\n" line cnum token
      end  
  )

let file_name = ref ""
 
let spec = [
  ("-f", Arg.Set_string file_name, "Parse file with WebIDL defenitions")
]

let () =
  Arg.parse spec print_endline "-f filename.idl";
  if !file_name = ""
  then print_endline "filename not defined"
  else parse !file_name


