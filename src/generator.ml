module Sexp = Sexplib.Sexp

let rec tab n =
  match n with
  | 0 -> ""
  | _ -> "    " ^ (tab (n - 1))

let o = print_endline

let map_default f def o =
  match o with
  | Some v -> f v
  | None -> def

module Type = struct 
  type t =
    | AsString of string
    | Int
    | Bool
    | Double
    | String
    | Void
    | Pointer of t
    | ConstPointer of t
    | Reference of t
    | ConstReference of t

  let rec to_string t =
    match t with
    | AsString s -> s
    | Int -> "int32_t"
    | Bool -> "bool"
    | Double -> "double"
    | String -> "std::string"
    | Void -> "void"
    | Pointer t' -> (to_string t') ^ "*"
    | ConstPointer t' -> (to_string t') ^ "const *"
    | Reference t' -> (to_string t') ^ "&"
    | ConstReference t' -> "const " ^ (to_string t') ^ "&"
end

module Expression = struct 
  type t =
    | FunCall of string * string list
    | Alloc of Type.t * string list
    | Expr of string

  let to_string e =
    match e with
    | FunCall (name, args) -> name ^ "(" ^ (String.concat ", " args) ^ ")"
    | Alloc (t, args) -> Type.to_string t ^ "(" ^ (String.concat ", " args) ^ ")"
    | Expr e' -> e'
end

module Statement = struct 
  type var_declaration = {
    name: string;
    var_type: Type.t;
    init_by: Expression.t option;
  }
  type t = 
    | VarDeclaration of var_declaration

  let generate s =
    match s with
    | VarDeclaration v ->
       let initer = map_default (fun e -> " = " ^ Expression.to_string e) "" v.init_by in
       o (Type.to_string v.var_type ^ " " ^ v.name ^ initer)
end

module Function = struct 
  type t = {
    name: string;
    return_type: Type.t;
    static: bool;
    arguments: (Type.t * string) list;
    body: Statement.t list;
  }

  let generate_declaration f =
    let static = if f.static then "static " else "" in
    let arg_to_str (t, name) = Type.to_string t ^ " " ^ name in
    let args = "(" ^ String.concat ", " (List.map arg_to_str f.arguments) ^ ")" in
    static ^ (Type.to_string f.return_type) ^ " " ^ f.name ^ args ^ ";"
end

module Member = struct
  type t =
    | Function of Function.t
    | Field of string * Type.t
  let generate_declaration m =
    match m with
    | Function f ->
       o (tab 1 ^ Function.generate_declaration f)
    | Field (name, t) -> 
       o (tab 1 ^ Type.to_string t ^ " " ^ name)
end

module Class = struct
  type t = {
    name: string;
    members: Member.t list;
  }

  let generate_declaration c =
    o ("class " ^ c.name ^ " {");
    List.iter Member.generate_declaration c.members;
    o "};"
end

let def_to_member (_args, def) =
  match def with
  | Ast.InterfaceAttribute attr ->
     let getter = Member.Function {
                      name = "get_" ^ attr.identifier;
                      return_type = Type.Void;
                      static = false;
                      arguments = [];
                      body = []
                    }
     in
     let setter = Member.Function {
                      name = "set_" ^ attr.identifier;
                      return_type = Type.Void;
                      static = false;
                      arguments = [];
                      body = []
                    }
     in
     if attr.readonly then [getter] else [getter; setter]

let generate (definitions:Ast.definitions) =
  let generate_item (attrs, def) =
    match def with
    | Ast.Interface i ->
       let members = List.flatten (List.map def_to_member i.members) in
       let c:Class.t = { members = members; name = i.identifier } in
       Class.generate_declaration c
    | _ -> print_endline (Sexp.to_string (Ast.sexp_of_full_definition (attrs, def)))
  in
  List.iter generate_item definitions
