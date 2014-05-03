type full_definition =
  attribute list * definition

and attribute =
  AttributeDummy

and definition =
  | Callback of callback
  | Interface of interface
  | CallbackInterface of callback_interface
  | PartialInterface of partial_interface
  | PartialDictionary of partial_dictionary
  | Dictionary of dictionary
  | ExceptionDef of exception_definition
  | Enum of enum
  | Typedef of typedef
  | ImplementsStatement of implements_statement

and callback =
  CallbackDummy

and interface = {
  members: (attribute list * interface_member) list;
  inheritance: identifier option;
}

and interface_member =   
  | ConstInterfaceMember 
  | InterfaceAttribute
  | InterfaceOperation
  | Stringifier

and partial_interface =
  | InterfacePartial

and callback_interface =
  | InterfaceCallback

and dictionary =
  | DictionaryDummy

and partial_dictionary =
  | DictionaryPartial

and exception_definition =
  ExceptionDummy

and enum =
  EnumDummy

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
