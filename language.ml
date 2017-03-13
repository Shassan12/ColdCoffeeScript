open Set

module CoffeeString = struct
	type t = string
	
	let rec compare s1 s2 =
		match s1, s2 with
			(* Empty strings. Lowest value of all *)
		    ":", ":" -> 0
		  | ":", _ -> -1
		  | _, ":" -> 1
			(* Prefixes of longer words have shorter value *)
		  | "", "" -> 0
		  | "", _ -> -1
		  | _, "" -> 1
		  | s1, s2 -> let score = (Pervasives.compare s1.[0] s2.[0]) in
				(if score == 0 then 
					(compare 
						(String.sub s1 1 (String.length s1 - 1))
						(String.sub s2 1 (String.length s2 - 1)))
					else score);;
	
	let stringConcat s1 s2 =
		match s1, s2 with
			":", s -> s
		  | s, ":" -> s
		  | s1, s2 -> s1 ^ s2;;
end
		  
module Language = Set.Make(CoffeeString);;

let rec display_aux s i = 
		if i == 1 then
			(Language.min_elt s) ^ "}"
		else
			let first = Language.min_elt s in
				first ^ "," ^ (display_aux (Language.remove first s) (i - 1));;
	
(*Set containing "t", "e", "s" and ":" would be displayed as "{:,e}" when i = 2*)
let display s i = 
	if i <= 0 then "{}"
	else
		"{" ^ (display_aux s (min i (Language.cardinal s)));;

let rec concat_aux s1 s2 olds2 l =
	if Language.is_empty s1 then l
	else
		if Language.is_empty s2 then
			concat_aux 	(Language.remove (Language.min_elt s1) s1)
						olds2 
						olds2
						l
		else
			concat_aux 	s1 
						(Language.remove (Language.min_elt s2) s2) 
						olds2
						(Language.add (CoffeeString.stringConcat (Language.min_elt s1) (Language.min_elt s2)) l);;

let concat olds1 olds2 = 
	let s1 = olds1 in
		let s2 = olds2 in
			concat_aux s1 s2 olds2 Language.empty;;