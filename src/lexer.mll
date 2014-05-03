(* header *)
{
open Lexing

type my_token =
  | Integer of int
  | Identifier of string
}

let hex_char = ['a'-'z' 'A'-'Z' '0'-'9']
let hex_integer =
  ['X' 'x'] hex_char+
let oct_integer =
  '0' ['0'-'7']*
let decimal_integer =
  ['1'-'9'] ['0'-'9']*
let integer =
  ('-'? (oct_integer | hex_integer | decimal_integer)) as int_str

let identifier =
  (['a'-'z' 'A'-'Z' '_'] ['0'-'9' 'a'-'z' 'A'-'Z' '_']) as ident_str

rule token = parse
  | integer { Integer (int_of_string int_str) }
  | identifier { Identifier ident_str }
