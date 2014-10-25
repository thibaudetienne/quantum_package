open Core.Std;;
open Qptypes;;

type t = (Symmetry.Xyz.t * Gto.t * Nucl_number.t ) list with sexp

let of_basis b =
  let rec do_work accu = function
    | [] -> accu
    | (g,n)::tail ->
        begin
          let new_accu = 
            Symmetry.Xyz.of_symmetry g.Gto.sym 
            |> List.map ~f:(fun x-> (x,g,n)) 
          in
          do_work (new_accu@accu) tail
        end
  in
  do_work [] b
  |> List.rev
;;


let to_string b =
  Sexp.to_string (sexp_of_t b)
;;
(*
  let middle = List.map ~f:(fun (x,y,z) -> 
     "( "^((Int.to_string (Nucl_number.to_int z)))^", "^
     (Symmetry.Xyz.to_string x)^", "^(Gto.to_string y)
     ^" )"
  ) b
  |> String.concat ~sep:",\n"
  in "("^middle^")"
;;
*)
