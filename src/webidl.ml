type single_type =
  | DOMString
  | Object
  | Date
  | Boolean
  | Byte
  | Octet

type webidl_type =
  | Void
  | SingleType of single_type
  | UnionType of webidl_type list

type callback = {
  indentifier: string;
  return_type: webidl_type;
  arguments: (string * webidl_type) list;
}

type definition =
  | Callback of callback
  | Interface
  | ParitalInterface
  | Dictionary
  | Exception
  | Enum
  | Typedef
  | ImplementsStatement

type webidl_fragment = definition list
