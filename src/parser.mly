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
%type <Ast.full_definition list> definitions

%%

/* rules */

definitions:
    extended_attribute_list definition definitions { ($1, $2) :: $3 }
  | EOF { [] }
;

definition:
    callback_or_interface { $1 }
  | partial { $1 }
  | dictionary { Dictionary $1 }
  | exception_rule { $1 } 
  | enum { Enum $1 }
  | typedef { $1 }
  | implements_statement { $1 }
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
  INTERFACE IDENTIFIER inheritance LBRACE interface_members RBRACE SEMI {
    { identifier = $2; members = $5; inheritance = $3 }
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
  INTERFACE IDENTIFIER LBRACE interface_members RBRACE SEMI {
    { identifier = $2; members = $4 }
  }
;

interface_members:
    /* empty */ { [] }
  | extended_attribute_list interface_member interface_members { ($1, $2) :: $3 }
;

interface_member:
    const { $1 }
  | attribute_or_operation { $1 }
;

dictionary:
  DICTIONARY IDENTIFIER inheritance LBRACE dictionary_members RBRACE SEMI {
    DictionaryDummy
  }
;

dictionary_members:
    /* empty */ { [] }
  | extended_attribute_list dictionary_member dictionary_members { ($1, $2) :: $3 }
;

dictionary_member:
  type_rule IDENTIFIER default SEMI { }
;

partial_dictionary:
  DICTIONARY IDENTIFIER LBRACE dictionary_members RBRACE {
    DictionaryPartial
  }
;

default:
    /* empty */ { None }
  | EQUAL default_value { Some $2 }
;

default_value:
    const_value { $1 }
  | STRING { String $1 }
;

exception_rule:
  EXCEPTION IDENTIFIER inheritance LBRACE exception_members RBRACE SEMI {
    ExceptionDef ExceptionDummy
  }
;

exception_members:
    /* empty */ { [] }
  | extended_attribute_list exception_member exception_members { ($1, $2) :: $3 }
;

inheritance:
    /* empty */ { None }
  | COLON IDENTIFIER { Some $2 }
;

enum:
  ENUM IDENTIFIER LBRACE enum_value_list RBRACE SEMI {
    { identifier = $2; members = $4 }
  }
;

enum_value_list:
  STRING enum_values { $1 :: $2 }
;

enum_values:
    /* empty */ { [] }
  | COMMA STRING enum_values { $2 :: $3 }
;

callback_rest:
  IDENTIFIER EQUAL return_type LRBRACKET argument_list RRBRACKET SEMI {
    { identifier = $1; return_type = $3; arguments = $5 }
  }
;

typedef:
  TYPEDEF extended_attribute_list type_rule IDENTIFIER SEMI {
    Typedef TypedefDummy
  }
;

implements_statement:
  IDENTIFIER IMPLEMENTS IDENTIFIER SEMI {
    ImplementsStatement ImplementsStatementDummy
  }
;

const:
  CONST const_type IDENTIFIER EQUAL const_value SEMI {
    ConstInterfaceMember {
      const_type = $2;
      identifier = $3;
      value = $5;
    }
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
  inherit_rule read_only ATTRIBUTE type_rule IDENTIFIER SEMI {
    { inherited = $1; readonly = $2; attrtype = $4; identifier = $5 }
  }
;

inherit_rule:
    /* empty */ { false }
  | INHERIT { true }
;

read_only:
    /* empty */ { false }
  | READONLY { true }
;

operation:
  qualifiers operation_rest {
    { $2 with qualifiers = $1 }
  }
;

qualifiers:
    STATIC { Static }
  | specials { Specials $1 }
;

specials: 
    /* empty */ { [] }
  | special specials { $1 :: $2 }
;

special:
    GETTER { Getter }
  | SETTER { Setter }
  | CREATOR { Creator }
  | DELETER { Deleter }
  | LEGACYCALLER { LegacyCaller }
;

operation_rest:
  return_type optional_identifier LRBRACKET argument_list RRBRACKET SEMI {
    { return_type = $1; identifier = $2; qualifiers = Static; arguments = $4 }
  }
;

optional_identifier:
    /* empty */ { None }
  | IDENTIFIER { Some $1 }
;

argument_list:
    /* empty */ { [] }
  | argument arguments { $1 :: $2 } 
;

arguments:
    /* empty */ { [] }
  | COMMA argument arguments { $2 :: $3 }
;

argument:
  extended_attribute_list optional_or_required_argument {
    ($1, $2)
  }
;

optional_or_required_argument:
    OPTIONAL type_rule argument_name default {
      OptionalArgument {
        default_value = $4;
        argtype = $2;
        name = $3;
      }
             }
  | type_rule ellipsis argument_name {
      if $2
      then RestArgument { name = $3; argtype = $1 }
      else RequiredArgument { name = $3; argtype = $1 }
    }
;

argument_name:
    argument_name_keyword { $1 }
  | IDENTIFIER { $1 }
;

ellipsis:
    /* empty */ { true }
  | ELLIPSIS { false }
;

exception_member:
    const {}
  | exception_field {}
;

exception_field:
  type_rule IDENTIFIER SEMI {}
;

extended_attribute_list:
    /* empty */ { [] }
  | LSBRACKET extended_attribute extended_attributes RSBRACKET { [] }
;

extended_attributes:
    /* empty */ { [] }
  | COMMA extended_attribute extended_attributes { $2 :: $3 }
;

extended_attribute:
  | LRBRACKET extended_attribute_inner RRBRACKET extended_attribute_rest {}
  | LSBRACKET extended_attribute_inner RSBRACKET extended_attribute_rest {}
  | LBRACE extended_attribute_inner RBRACE extended_attribute_rest {}
  | other extended_attribute_rest {}
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

argument_name_keyword:
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
  | SEQUENCE LESS type_rule GREATER null { Sequence ($3, $5), [] }
  | OBJECT type_suffix { Object, $2 }
  | DATE type_suffix { Date, $2 }
;

const_type:
    primitive_type null { PrimitiveType ($1, $2) }
  | IDENTIFIER null { UserType ($1, $2) }
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
    FLOAT { Float }
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

null:
    /* empty */ { false }
  | QUESTION { true }
;

return_type:
    type_rule { NonVoid $1 }
  | VOID { Void }
;

extended_attribute_no_args:
  IDENTIFIER {}
;

extended_attribute_arg_list:
  IDENTIFIER LRBRACKET argument_list RRBRACKET {}
;

extended_attribute_ident:
  IDENTIFIER EQUAL IDENTIFIER {}
;

extended_attribute_named_arg_list:
  IDENTIFIER EQUAL IDENTIFIER LSBRACKET argument_list RSBRACKET {}
;

%%

