{
  open Parser

  exception Lexing_error of string
}

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z' '_']
let alphanum = alpha | digit
let whitespace = [' ' '\t']

rule token = parse
  | whitespace+    { token lexbuf }
  | '\n'           { Lexing.new_line lexbuf; token lexbuf }
  | "let"          { LET }
  | "print"        { PRINT }
  | digit+ as n    { INT n }
  | alpha alphanum* as id { IDENT id }
  | '+'            { PLUS }
  | '-'            { MINUS }
  | '*'            { STAR }
  | '='            { EQUALS }
  | '('            { LPAREN }
  | ')'            { RPAREN }
  | eof            { EOF }
  | _ as c         { raise (Lexing_error (Printf.sprintf "Unexpected character: %c" c)) }
