(* header *)
{
open Lexing
open Parser

let create_hashtable values =
  let l = List.length values in
  let tbl = Hashtbl.create l in
  List.iter (fun (str, token) -> Hashtbl.add tbl str token) values;
  tbl

let keyword_table =
  create_hashtable [
    "callback", CALLBACK;
    "interface", INTERFACE;
    "partial", PARTIAL;
    "dictionary", DICTIONARY;
    "exception", EXCEPTION;
    "enum", ENUM;
    "typedef", TYPEDEF;
    "implements", IMPLEMENTS;
    "const", CONST;
    "null", NULL;
    "true", TRUE;
    "false", FALSE;
    "Infinity", INFINITY;
    "NaN", NAN;
    "stringifier", STRINGIFIER;
    "attribute", ATTRIBUTE;
    "inherit", INHERIT;
    "readonly", READONLY;
    "getter", GETTER;
    "setter", SETTER;
    "creator", CREATOR;
    "deleter", DELETER;
    "legacycaller", LEGACYCALLER;
    "optional", OPTIONAL;
    "DOMString", DOMSTRING;
    "any", ANY;
    "boolean", BOOLEAN;
    "byte", BYTE;
    "double", DOUBLE;
    "float", FLOAT_TYPE;
    "long", LONG;
    "object", OBJECT;
    "octet", OCTET;
    "or", OR;
    "sequence", SEQUENCE;
    "short", SHORT;
    "unsigned", UNSIGNED;
    "void", VOID;
    "unrestricted", UNRESTRICTED;
    "static", STATIC;
  ]

let make_identifier str =
  if str.[0] = '_'
  then String.sub str 1 (String.length str - 1)
  else str

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

let float_mantissa = 
  (['0'-'9']+'.'['0'-'9']*|['0'-'9']*'.'['0'-'9']+)

let float =
  ('-'? (float_mantissa (['E' 'e' ]['+' '-']? ['0'-'9']+)?) 
    | (['0'-'9']+ ['E' 'e'] ['+' '-']? ['0'-'9']+)) as float_str

let identifier =
  (['a'-'z' 'A'-'Z' '_'] ['0'-'9' 'a'-'z' 'A'-'Z' '_']*) as ident_str

let string = '"' ([^ '"']* as str) '"'

let other = [^ '\t' '\n' '\r' '0'-'9' 'A'-'Z' 'a'-'z']

let single_line_comment = "//" [^'\n']* '\n'
let multi_line_comment = "/*" (([^'*']* '*')*)? '/'

let whitespace =
  (['\t' '\n' '\r' ' ']+) | (['\t' '\n' '\r']* ((single_line_comment | multi_line_comment) ['\t' '\n' '\r']*)+)

rule token = parse
  | float { FLOAT (float_of_string float_str) } 
  | integer { INTEGER (int_of_string int_str) }
  | whitespace { token lexbuf }
  | identifier {
        try Hashtbl.find keyword_table ident_str
        with Not_found -> IDENTIFIER (make_identifier ident_str)
      }
  | string { STRING str }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | ';' { SEMI }
  | '=' { EQUAL }
  | ':' { COLON }
  | ',' { COMMA }
  | '(' { LRBRACKET }
  | ')' { RRBRACKET }
  | '-' { MINUS }
  | "..." { ELLIPSIS }
  | '.' { DOT }
  | '<' { LESS }
  | '>' { GREATER }
  | '?' { QUESTION }
  | '[' { LSBRACKET }
  | ']' { RSBRACKET }
  | eof { EOF }
