open Sexplib.Std

type definitions = full_definition list

and full_definition =
  extended_attribute list * definition

and extended_attribute =
  AttributeDummy

and definition =
  | Callback of callback
  | Interface of interface
  | CallbackInterface of interface
  | PartialInterface of partial_interface
  | PartialDictionary of partial_dictionary
  | Dictionary of dictionary
  | ExceptionDef of exception_definition
  | Enum of enum
  | Typedef of typedef
  | ImplementsStatement of implements_statement

and callback = {
  identifier: string;
  return_type: return_type;
  arguments: (extended_attribute list * argument) list;
}

and argument =
  | OptionalArgument of optional_argument
  | RestArgument of rest_argument
  | RequiredArgument of required_argument

and optional_argument = {
  default_value: const_value option;
  argtype: type_description;
  name: identifier;
}

and rest_argument = {
  name: identifier;
  argtype: type_description;
}

and required_argument = {
  name: identifier;
  argtype: type_description;
}

and interface = {
  identifier: string;
  members: (extended_attribute list * interface_member) list;
  inheritance: identifier option;
}

and interface_member =   
  | ConstInterfaceMember of const_member
  | InterfaceAttribute of attribute
  | InterfaceOperation of operation
  | Stringifier

and const_member = {
  const_type: const_type;
  identifier: identifier;
  value: const_value;
}

and attribute = {
  inherited: bool;
  readonly: bool;
  identifier: identifier;
  attrtype: type_description;
}

and operation = {
  return_type: return_type;
  identifier: identifier option;
  qualifiers: qualifier option;
  arguments: (extended_attribute list * argument) list;
}

and qualifier =
  | Static
  | Specials of special list

and special =
  | Getter
  | Setter
  | Creator
  | Deleter
  | LegacyCaller

and partial_interface = {
  identifier: string;
  members: (extended_attribute list * interface_member) list;
}

and callback_interface =
  | InterfaceCallback

and dictionary = {
  identifier: identifier;
  inheritance: identifier option;
  members: (extended_attribute list * dictionary_member) list;
}

and dictionary_member = {
  member_type: type_description;
  identifier: identifier;
  default_value: const_value option;
}

and partial_dictionary = {
  identifier: identifier;
  members: (extended_attribute list * dictionary_member) list
}

and exception_definition = {
  identifier: identifier;
  inheritance: identifier option;
  members: (extended_attribute list * exception_member) list;
}

and exception_member =
  | ConstExceptionMember of const_member
  | ExceptionField of exception_field

and exception_field = {
  identifier: identifier;
  exception_type: type_description;
}

and enum = {
  identifier: string;
  members: string list;
}

and typedef = {
  attributes: extended_attribute list;
  aliased_type: type_description;
  identifier: identifier;
}

and implements_statement = {
  child: identifier;
  parent: identifier;
}

and identifier = string

and extended_attribute_list =
  ExtendedAttributeList

and type_description = concrete_type * type_suffix

and concrete_type =
  | AnyArray
  | DomString
  | Identifier of identifier
  | UnionType of type_description list
  | Object
  | Date
  | Primitive of primitive_type
  | Sequence of type_description * optional (* TODO: can't has type_suffix *)

and primitive_type =
  | UShort
  | ULong
  | ULongLong
  | Short
  | Long
  | LongLong
  | Float
  | Double
  | UFloat
  | UDouble
  | Boolean
  | Byte
  | Octet

and type_suffix = suffix list

and suffix = Array | Optional

and optional = bool

and const_type =
  | PrimitiveType of primitive_type * optional
  | UserType of identifier * optional

and return_type = 
  | Void
  | NonVoid of type_description

and const_value =
  | True
  | False
  | FloatLiteral of float_literal
  | Integer of int
  | Null
  | String of string

and float_literal =
  | FloatValue of float
  | MinusInfinity
  | Infinity
  | NaN
  with sexp_of
