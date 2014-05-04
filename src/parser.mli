type token =
  | EOF
  | CALLBACK
  | INTERFACE
  | LBRACE
  | RBRACE
  | SEMI
  | PARTIAL
  | IDENTIFIER of (string)
  | DICTIONARY
  | EQUAL
  | STRING of (string)
  | EXCEPTION
  | COLON
  | COMMA
  | ENUM
  | LRBRACKET
  | RRBRACKET
  | TYPEDEF
  | IMPLEMENTS
  | CONST
  | INTEGER of (int)
  | NULL
  | TRUE
  | FALSE
  | FLOAT of (float)
  | MINUS
  | INFINITY
  | NAN
  | STRINGIFIER
  | ATTRIBUTE
  | INHERIT
  | READONLY
  | GETTER
  | SETTER
  | CREATOR
  | DELETER
  | LEGACYCALLER
  | OPTIONAL
  | ELLIPSIS
  | LSBRACKET
  | RSBRACKET
  | OTHER of (string)
  | DOT
  | LESS
  | GREATER
  | QUESTION
  | DATE
  | DOMSTRING
  | ANY
  | BOOLEAN
  | BYTE
  | DOUBLE
  | FLOAT_TYPE
  | LONG
  | OBJECT
  | OCTET
  | OR
  | SEQUENCE
  | SHORT
  | UNSIGNED
  | VOID
  | UNRESTRICTED
  | STATIC

val definitions :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.definitions
