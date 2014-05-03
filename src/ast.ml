type full_definition =
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
  return_type: unit;
  arguments: (extended_attribute list * argument) list;
}

and argument =
  | OptionalArgument of optional_argument
  | RestArgument of rest_argument
  | RequiredArgument of required_argument

and optional_argument = {
  default_value: string option;
  argtype: unit;
  name: identifier;
}

and rest_argument = {
  name: identifier;
  argtype: unit;
}

and required_argument = {
  name: identifier;
  argtype: unit;
}

and interface = {
  identifier: string;
  members: (extended_attribute list * interface_member) list;
  inheritance: identifier option;
}

and interface_member =   
  | ConstInterfaceMember 
  | InterfaceAttribute of attribute
  | InterfaceOperation of operation
  | Stringifier

and attribute = {
  inherited: bool;
  readonly: bool;
  identifier: identifier;
  attrtype: unit;
}

and operation = {
  identifier: identifier option;
  qualifiers: qualifier;
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

and dictionary =
  | DictionaryDummy

and partial_dictionary =
  | DictionaryPartial

and exception_definition =
  ExceptionDummy

and enum = {
  identifier: string;
  members: string list;
}

and typedef =
  TypedefDummy

and implements_statement =
  ImplementsStatementDummy

and identifier = string

and extended_attribute_list =
  ExtendedAttributeList

and integer_type =
  | Short
  | Long
  | LongLong
