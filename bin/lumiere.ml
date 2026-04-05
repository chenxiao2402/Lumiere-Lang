let () : unit =
  if Array.length Sys.argv < 2 then (
    Printf.eprintf "Usage: lumiere <file.lum> [--emit-llvm]\n";
    exit 1
  );
  let (filename : string) = Sys.argv.(1) in
  let (emit_llvm_only : bool) =
    Array.length Sys.argv > 2 && Sys.argv.(2) = "--emit-llvm"
  in
  let (ic : in_channel) = open_in filename in
  let (lexbuf : Lexing.lexbuf) = Lexing.from_channel ic in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
  let (ast : Lumiere_lib.Ast.program) =
    try Lumiere_lib.Parser.program Lumiere_lib.Lexer.token lexbuf
    with
    | Lumiere_lib.Lexer.Lexing_error msg ->
      let (pos : Lexing.position) = lexbuf.lex_curr_p in
      Printf.eprintf "%s:%d:%d: Lexing error: %s\n"
        pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol) msg;
      exit 1
    | Lumiere_lib.Parser.Error ->
      let (pos : Lexing.position) = lexbuf.lex_curr_p in
      Printf.eprintf "%s:%d:%d: Parse error\n"
        pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol);
      exit 1
  in
  close_in ic;
  let (llvm_ir : string) = Lumiere_lib.Codegen.codegen ast in
  if emit_llvm_only then
    print_string llvm_ir
  else begin
    let (base : string) = Filename.remove_extension filename in
    let (ll_file : string) = base ^ ".ll" in
    let (out_file : string) = base in
    let (oc : out_channel) = open_out ll_file in
    output_string oc llvm_ir;
    close_out oc;
    let (clang : string) = "/opt/homebrew/opt/llvm/bin/clang" in
    let (cmd : string) = Printf.sprintf "%s -Wno-override-module %s -lgmp -L/opt/homebrew/opt/gmp/lib -o %s 2>&1"
      (Filename.quote clang) (Filename.quote ll_file) (Filename.quote out_file)
    in
    let (ret : int) = Sys.command cmd in
    if ret <> 0 then (
      Printf.eprintf "Compilation failed (clang exit code %d)\n" ret;
      exit 1
    );
    Printf.printf "Compiled to %s\n" out_file
  end
