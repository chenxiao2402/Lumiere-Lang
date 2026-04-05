(** AST for the Lumiere language *)

type expr =
  | IntLit of string
  | Var of string
  | BinOp of binop * expr * expr

and binop = Add | Sub | Mul

type stmt =
  | Let of string * expr
  | Print of expr

type program = stmt list
