%{

open Ast

%}

/* declarations */

%token EOF
%token CALLBACK
%token INTERFACE
%token LBRACE
%token RBRACE
%token SEMI
%token PARTIAL
%token <string> IDENTIFIER
%token DICTIONARY
%token EQUAL
%token <string> STRING
%token EXCEPTION
%token COLON
%token COMMA
%token ENUM
%token LRBRACKET
%token RRBRACKET
%token TYPEDEF
%token IMPLEMENTS
%token CONST
%token <int> INTEGER
%token NULL
%token TRUE
%token FALSE
%token <float> FLOAT
%token MINUS
%token INFINITY
%token NAN
%token STRINGIFIER
%token ATTRIBUTE
%token INHERIT
%token READONLY
%token GETTER
%token SETTER
%token CREATOR
%token DELETER
%token LEGACYCALLER
%token OPTIONAL
%token ELLIPSIS
%token LSBRACKET
%token RSBRACKET
%token <string> OTHER
%token DOT
%token LESS
%token GREATER
%token QUESTION
%token DATE
%token DOMSTRING
%token ANY
%token BOOLEAN
%token BYTE
%token DOUBLE
%token FLOAT_TYPE
%token LONG
%token OBJECT
%token OCTET
%token OR
%token SEQUENCE
%token SHORT
%token UNSIGNED
%token VOID
%token UNRESTRICTED
%token STATIC

%start definitions
%type <Ast.definitions> definitions
%type <Ast.definition> definition
%type <Ast.interface> interface
%type <Ast.partial_interface> partial_interface
%type <Ast.dictionary> dictionary
%type <Ast.partial_dictionary> partial_dictionary
%type <Ast.exception_definition> exception_rule
%type <Ast.const_value> default_value

%%

/* rules */

definitions:
  ds=list(pair(extended_attribute_list, definition)) EOF { ds }
;

definition:
    callback_or_interface { $1 }
  | partial { $1 }
  | dictionary { Dictionary $1 }
  | exception_rule { ExceptionDef $1 } 
  | enum { Enum $1 }
  | typedef { Typedef $1 }
  | implements_statement { ImplementsStatement $1 }
;

callback_or_interface:
    CALLBACK callback_rest_or_interface { $2 }
  | interface { Interface $1 }
;

callback_rest_or_interface:
    callback_rest { Callback $1 }
  | interface { CallbackInterface $1 }
;

interface:
  INTERFACE n=IDENTIFIER i=inheritance ms=members(interface_member) SEMI {
    { identifier = n; members = ms; inheritance = i }
  }
;

partial:
  PARTIAL partial_definition { $2 }
;

partial_definition:
    partial_interface { PartialInterface $1 }
  | partial_dictionary { PartialDictionary $1 }
;

partial_interface:
  INTERFACE n=IDENTIFIER ms=members(interface_member) SEMI {
    { identifier = n; members = ms }
  }
;

members(Member):
  ms=delimited(LBRACE, list(pair(extended_attribute_list, Member)), RBRACE) { ms } 
;

interface_member:
    const { ConstInterfaceMember $1 }
  | attribute_or_operation { $1 }
;

dictionary:
  DICTIONARY n=IDENTIFIER i=inheritance ms=members(dictionary_member) SEMI {
    { identifier = n; inheritance = i; members = ms }
  }
;

dictionary_member:
  t=type_rule n=IDENTIFIER d=option(default) SEMI {
    { identifier = n; member_type = t; default_value = d }
  }
;

partial_dictionary:
  DICTIONARY n=IDENTIFIER ms=members(dictionary_member) SEMI {
    { identifier = n; members = ms }
  }
;

default:
  | EQUAL default_value { $2 }
;

default_value:
    const_value { $1 }
  | STRING { String $1 }
;

exception_rule:
  EXCEPTION n=IDENTIFIER i=inheritance ms=members(exception_member) SEMI {
    { identifier = n; inheritance = i; members = ms }
  }
;

inheritance:
    /* empty */ { None }
  | COLON IDENTIFIER { Some $2 }
;

enum:
  ENUM n=IDENTIFIER ms=delimited(LBRACE, separated_list(COMMA, STRING), RBRACE) SEMI {
    { identifier = n; members = ms }
  }
;

callback_rest:
  n=IDENTIFIER EQUAL t=return_type a=plist(argument) SEMI {
    { identifier = n; return_type = t; arguments = a }
  }
;

typedef:
  TYPEDEF extended_attribute_list type_rule IDENTIFIER SEMI {
    { attributes = $2; aliased_type = $3; identifier = $4 }
  }
;

implements_statement:
  IDENTIFIER IMPLEMENTS IDENTIFIER SEMI {
    { child = $1; parent = $3 }
  }
;

const:
  CONST const_type IDENTIFIER EQUAL const_value SEMI {
    { const_type = $2; identifier = $3; value = $5; }
  }
;

const_value:
    boolean_literal { $1 }
  | float_literal { FloatLiteral $1 }
  | INTEGER { Integer $1 }
  | NULL { Null }
;

boolean_literal:
    TRUE { True }
  | FALSE { False }
;

float_literal:
    FLOAT { FloatValue $1 }
  | MINUS INFINITY { MinusInfinity }
  | INFINITY { Infinity }
  | NAN { NaN }
;

attribute_or_operation:
    STRINGIFIER stringifier_attribute_or_operation { Stringifier }
  | attribute { InterfaceAttribute $1 }
  | operation { InterfaceOperation $1 }
;

stringifier_attribute_or_operation:
    attribute {}
  | operation_rest {}
  | SEMI {}
;

attribute:
  i=boption(INHERIT) r=boption(READONLY) ATTRIBUTE t=type_rule n=IDENTIFIER SEMI {
    { inherited = i; readonly = r; attrtype = t; identifier = n }
  }
;

operation:
  qualifiers operation_rest {
    { $2 with qualifiers = $1 }
  }
;

qualifiers:
    STATIC { Some Static }
  | s=list(special) {
      match s with
      | [] -> None
      | _ -> Some (Specials s)
    }
;

special:
    GETTER { Getter }
  | SETTER { Setter }
  | CREATOR { Creator }
  | DELETER { Deleter }
  | LEGACYCALLER { LegacyCaller }
;

operation_rest:
  t=return_type n=option(IDENTIFIER) a=plist(argument) SEMI {
    { return_type = t; identifier = n; qualifiers = None; arguments = a }
  }
;

%inline plist(X):
  a=delimited(LRBRACKET, separated_list(COMMA, X), RRBRACKET) { a }

argument:
  a=pair(extended_attribute_list, optional_or_required_argument) {a}
;

optional_or_required_argument:
    OPTIONAL t=type_rule n=argument_name d=option(default) {
      OptionalArgument {
        default_value = d;
        argtype = t;
        name = n;
      }
             }
  | t=type_rule e=boption(ELLIPSIS) n=argument_name {
      if e
      then RestArgument { name = n; argtype = t }
      else RequiredArgument { name = n; argtype = t }
    }
;

argument_name:
    n=argument_name_keyword { n }
  | n=IDENTIFIER { n }
;

exception_member:
    const { ConstExceptionMember $1 }
  | exception_field { ExceptionField $1 }
;

exception_field:
  t=type_rule n=IDENTIFIER SEMI {
    { identifier = n; exception_type = t }
  }
;

extended_attribute_list:
  a=loption(delimited(LSBRACKET, separated_list(COMMA, extended_attribute), RSBRACKET)) { a }
;

extended_attribute:
  | LRBRACKET extended_attribute_inner RRBRACKET extended_attribute_rest { AttributeDummy }
  | LSBRACKET extended_attribute_inner RSBRACKET extended_attribute_rest { AttributeDummy }
  | LBRACE extended_attribute_inner RBRACE extended_attribute_rest {AttributeDummy }
  | other extended_attribute_rest { AttributeDummy }
;

extended_attribute_rest:
    /* empty */ { }
  | extended_attribute {}
;

extended_attribute_inner:
    /* empty */ { [] }
  | LRBRACKET extended_attribute_inner RRBRACKET extended_attribute_inner { [] }
  | LSBRACKET extended_attribute_inner RSBRACKET extended_attribute_inner { [] }
  | LBRACE extended_attribute_inner RBRACE extended_attribute_inner { [] }
  | other_or_comma extended_attribute_inner { [] }
; 

other:
    INTEGER {}
  | FLOAT {}
  | IDENTIFIER {}
  | STRING {}
  | OTHER {}
  | MINUS {}
  | DOT {}
  | COLON {}
  | SEMI {}
  | LESS {}
  | EQUAL {}
  | GREATER {}
  | QUESTION {}
  | DATE {}
  | DOMSTRING {}
  | INFINITY {}
  | NAN {}
  | ANY {}
  | BOOLEAN {}
  | BYTE {}
  | DOUBLE {}
  | FALSE {}
  | FLOAT_TYPE {}
  | LONG {}
  | NULL {}
  | OBJECT {}
  | OCTET {}
  | OR {}
  | OPTIONAL {}
  | SEQUENCE {}
  | SHORT {}
  | TRUE {}
  | UNSIGNED {}
  | VOID {}
  | argument_name_keyword {}
;

%inline argument_name_keyword:
    ATTRIBUTE { "attribute" }
  | CALLBACK { "callback" }
  | CONST { "const" }
  | CREATOR { "creator" }
  | DELETER { "deleter" }
  | DICTIONARY { "dictionary" }
  | ENUM { "enum" }
  | EXCEPTION { "exception" }
  | GETTER { "getter" }
  | IMPLEMENTS { "implements" }
  | INHERIT { "inherit" }
  | INTERFACE { "interface" }
  | LEGACYCALLER { "legacycaller" }
  | PARTIAL { "partial" }
  | SETTER { "setter" }
  | STATIC { "static" }
  | STRINGIFIER { "strinifier" }
  | TYPEDEF { "typedef" }
  | UNRESTRICTED { "unrestricted" }
;

other_or_comma:
    other {}
  | COMMA {}
;

type_rule:
    single_type { $1 }
  | union_type type_suffix { (UnionType $1), $2 }
;

single_type:
    non_any_type { $1 }
  | ANY LSBRACKET RSBRACKET type_suffix { AnyArray, $4 }
;

union_type:
    /* empty */ { [] }
  | LRBRACKET union_member_type OR union_member_type union_member_types RRBRACKET {
    $2 :: $4 :: $5
  }
;

union_member_type:
    non_any_type { $1 }
  | union_type type_suffix { UnionType $1, $2 }
  | ANY LSBRACKET RSBRACKET type_suffix { AnyArray, $4 }
;

union_member_types:
    /* empty */ { [] }
  | OR union_member_type union_member_types { $2 :: $3 }
;

non_any_type:
    primitive_type type_suffix { Primitive $1, $2 }
  | DOMSTRING type_suffix { DomString, $2 }
  | IDENTIFIER type_suffix { Identifier $1, $2 }
  | SEQUENCE LESS t=type_rule GREATER n=null { Sequence (t, n), [] }
  | OBJECT type_suffix { Object, $2 }
  | DATE type_suffix { Date, $2 }
;

const_type:
    t=primitive_type n=null { PrimitiveType (t, n) }
  | i = IDENTIFIER n=null { UserType (i, n) }
;

primitive_type:
    unsigned_integer_type { $1 }
  | unrestricted_float_type { $1 }
  | BOOLEAN { Boolean }
  | BYTE { Byte }
  | OCTET { Octet }
;

unrestricted_float_type:
    UNRESTRICTED float_type {
      match $2 with
      | Float -> UFloat
      | Double -> UDouble
      | _ -> failwith "not float type"
    }
  | float_type { $1 }
;

float_type:
    FLOAT_TYPE { Float }
  | DOUBLE { Double }
;

unsigned_integer_type:
    UNSIGNED integer_type {
      match $2 with
      | Short -> UShort
      | Long -> ULong
      | LongLong -> ULongLong
      | _ -> failwith "not integer type"
    }
  | integer_type { $1 }
;

integer_type:
    SHORT { Short }
  | LONG optional_long { if $2 then LongLong else Long }
;

optional_long:
    /* empty */ { false }
  | LONG { true }
;

type_suffix:
    /* empty */ { [] }
  | QUESTION type_suffix_starting_with_array { Optional :: $2 }
  | LSBRACKET RSBRACKET type_suffix { Array :: $3 }
;

type_suffix_starting_with_array:
    /* empty */ { [] }
  | LSBRACKET RSBRACKET type_suffix { Array :: $3 }
;

%inline null:
  n = boption(QUESTION) { n }
;

return_type:
    type_rule { NonVoid $1 }
  | VOID { Void }
;

%%

