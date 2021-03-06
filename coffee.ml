(* File coffee.ml *)
exception IDoNotUnderstandAWhatAYouAreASayingError of string;;
exception KEesATuSmolError of string;;

open Lexer
open Parser
open CoffeeInterpreter
open Language
open Arg
open Str

let parseProgram c = 
	(*lexbuf is the buffer the lexer reads from*)
    try let lexbuf = Lexing.from_channel c in  
			(*Parse the result of lexing lexbuf*)
            main main_lex lexbuf 
    with Parsing.Parse_error -> failwith "Parse failure!";;
	
(*A set can be the empty set {}, or have at least one word separated with a ,*)
let set_regexp = regexp "{}\\|{\\(\\(:\\|\\([a-z]+\\)\\),\\)*\\(:\\|[a-z]+\\)}";;

let rec get_lists i = 
	(*Read the next line from stdin. Ignore whitespace*)
	let next_line = Str.global_replace (regexp "\t\\| ") "" (read_line ()) in
		try
			(*Probably a set. Check against set_regexp*)
			(if (string_match set_regexp next_line 0) then 
				(*Join tuple of the language name and set to recursive call*) 
				(
					(*L1 to Ln are the input sets*)
					"L"^(string_of_int i), 
					(*Split the words up using commas; convert resulting list to set*)
					TmSet (of_list_input (split 
												(regexp ",") 
												(*Remove curly braces before splitting*)
												(String.sub next_line 1 (String.length next_line - 2))))
				) :: get_lists (i + 1)
			else
				(*Probably the int K. Try converting to int*)
				let k = int_of_string next_line in
					(if (k < 0) 
						then raise (KEesATuSmolError ("'"^next_line^"' ees-a tu smol! Your integer must-a be tsero or more."))
					else [("K", TmInt k)]))
		(*Not a valid set or int*)
		with Failure "int_of_string" -> raise (IDoNotUnderstandAWhatAYouAreASayingError ("'"^next_line^"' does-a not look like a set or an integer.\nExample set: {gennaro,:,abc}\nExample integer: 26"));;
						
let rec input_type_check l =
	try
		match l with
			[] -> []
		  | (var, term) :: tail -> 
				(match term with 
					TmSet (s) -> (var, SetType) :: input_type_check tail
				  | TmInt (i) -> [(var, IntType)]
				  | _ -> raise (IDoNotUnderstandAWhatAYouAreASayingError ("What you 'ave written does-a not look like a set or an integer.\nExample set: {gennaro,:,abc}\nExample integer: 26")))
	with DecafError _ -> raise (IDoNotUnderstandAWhatAYouAreASayingError ("What you 'ave written does-a not look like a set or an integer.\nExample set: {gennaro,:,abc}\nExample integer: 26"));;
	  
	  
let progFile = ref stdin in
let setProg p = progFile := open_in p in
let usage = "./main PROGRAM_FILE" in
parse [] setProg usage ; 
let parsedProg = parseProgram !progFile in
let () = print_newline() in
let progEnv = get_lists 1 in
let typeEnv = input_type_check progEnv in
let _ = typeProg typeEnv parsedProg in
let () = print_newline() in
let _ = eval progEnv parsedProg in
let () = print_newline() in
flush stdout
