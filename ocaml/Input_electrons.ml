open Qptypes;;
open Qputils;;
open Core.Std;;

module Electrons : sig
  type t = 
    { elec_alpha_num     : Elec_alpha_number.t;
      elec_beta_num      : Elec_beta_number.t;
    } with sexp
  ;;
  val read  : unit -> t
  val write : t -> unit
  val read_elec_num : unit -> Elec_number.t
  val to_string : t -> string
  val to_rst : t -> Rst_string.t
  val of_rst : Rst_string.t -> t
end = struct
  type t = 
    { elec_alpha_num     : Elec_alpha_number.t;
      elec_beta_num      : Elec_beta_number.t;
    } with sexp
  ;;

  let get_default = Qpackage.get_ezfio_default "electrons";;

  let read_elec_alpha_num() = 
    Ezfio.get_electrons_elec_alpha_num ()
    |> Elec_alpha_number.of_int
  ;;

  let write_elec_alpha_num n = 
    Elec_alpha_number.to_int n
    |> Ezfio.set_electrons_elec_alpha_num 
  ;;


  let read_elec_beta_num() = 
    Ezfio.get_electrons_elec_beta_num ()
    |> Elec_beta_number.of_int
  ;;

  let write_elec_beta_num n = 
    Elec_beta_number.to_int n
    |> Ezfio.set_electrons_elec_beta_num 
  ;;

  let read_elec_num () = 
    let na = Ezfio.get_electrons_elec_alpha_num ()
    and nb = Ezfio.get_electrons_elec_beta_num  ()
    in assert (na >= nb);
    Elec_number.of_int (na + nb)
  ;;


  let read () = 
    { elec_alpha_num      = read_elec_alpha_num ();
      elec_beta_num       = read_elec_beta_num ();
    }
  ;;

  let write { elec_alpha_num ; elec_beta_num } =
    write_elec_alpha_num elec_alpha_num;
    write_elec_beta_num  elec_beta_num;
  ;;


  let to_rst b =
    Printf.sprintf "
Spin multiplicity is %s.

Number of alpha and beta electrons ::

  elec_alpha_num = %s
  elec_beta_num  = %s

"
        (Multiplicity.of_alpha_beta b.elec_alpha_num b.elec_beta_num
         |> Multiplicity.to_string)
        (Elec_alpha_number.to_string b.elec_alpha_num)
        (Elec_beta_number.to_string b.elec_beta_num)
    |> Rst_string.of_string
  ;;

  let to_string b =
    Printf.sprintf "elec_alpha_num     = %s
elec_beta_num      = %s
elec_num           = %s
"
        (Elec_alpha_number.to_string b.elec_alpha_num)
        (Elec_beta_number.to_string b.elec_beta_num)
        (Elec_number.to_string (read_elec_num ()))
  ;;

  let of_rst s =
    let s = Rst_string.to_string s
    |> String.split ~on:'\n'
    |> List.filter ~f:(fun line ->
        String.contains line '=')
    |> List.map ~f:(fun line ->
        "("^(
        String.tr line ~target:'=' ~replacement:' '
        )^")" )
    |> String.concat
    in
    Sexp.of_string ("("^s^")")
    |> t_of_sexp
  ;;

end

