%{
  open Ast
%}

%token <string> INT
%token <string> IDENT
%token LET PRINT
%token PLUS MINUS STAR
%token EQUALS
%token LPAREN RPAREN
%token EOF

%left PLUS MINUS
%left STAR

%start <Ast.program> program

%%

program:
  | stmts = list(stmt); EOF { stmts }

stmt:
  | LET; name = IDENT; EQUALS; e = expr { Let (name, e) }
  | PRINT; e = expr                      { Print e }

expr:
  | n = INT                              { IntLit n }
  | id = IDENT                           { Var id }
  | e1 = expr; PLUS; e2 = expr          { BinOp (Add, e1, e2) }
  | e1 = expr; MINUS; e2 = expr         { BinOp (Sub, e1, e2) }
  | e1 = expr; STAR; e2 = expr          { BinOp (Mul, e1, e2) }
  | LPAREN; e = expr; RPAREN            { e }
