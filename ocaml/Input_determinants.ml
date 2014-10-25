open Qptypes;;
open Qputils;;
open Core.Std;;

module Determinants : sig
  type t = 
    { n_int                  : N_int_number.t;
      bit_kind               : Bit_kind.t;
      mo_label               : Non_empty_string.t;
      n_det                  : Det_number.t;
      n_states               : States_number.t;
      n_states_diag          : States_number.t;
      n_det_max_jacobi       : Det_number.t;
      threshold_generators   : Threshold.t;
      threshold_selectors    : Threshold.t; 
      read_wf                : bool;
      expected_s2            : Positive_float.t;
      s2_eig                 : bool;
      psi_coef               : Det_coef.t array;
      psi_det                : Determinant.t array;
    } with sexp
  ;;
  val read : unit -> t
  val to_string : t -> string
end = struct
  type t = 
    { n_int                  : N_int_number.t;
      bit_kind               : Bit_kind.t;
      mo_label               : Non_empty_string.t;
      n_det                  : Det_number.t;
      n_states               : States_number.t;
      n_states_diag          : States_number.t;
      n_det_max_jacobi       : Det_number.t;
      threshold_generators   : Threshold.t;
      threshold_selectors    : Threshold.t; 
      read_wf                : bool;
      expected_s2            : Positive_float.t;
      s2_eig                 : bool;
      psi_coef               : Det_coef.t array;
      psi_det                : Determinant.t array;
    } with sexp
  ;;

  let get_default = Qpackage.get_ezfio_default "determinants";;

  let read_n_int () =
    if not (Ezfio.has_determinants_n_int()) then
       Ezfio.get_mo_basis_mo_tot_num ()
       |> Bitlist.n_int_of_mo_tot_num
       |> N_int_number.to_int
       |> Ezfio.set_determinants_n_int
    ;
    Ezfio.get_determinants_n_int ()
    |> N_int_number.of_int
  ;;

  let read_bit_kind () =
    if not (Ezfio.has_determinants_bit_kind ()) then
      Lazy.force Qpackage.bit_kind
      |> Bit_kind.to_int
      |> Ezfio.set_determinants_bit_kind
    ;
    Ezfio.get_determinants_bit_kind ()
    |> Bit_kind.of_int
  ;;

  let read_mo_label () =
    if (not (Ezfio.has_determinants_mo_label ())) then
      Ezfio.get_mo_basis_mo_label ()
      |> Ezfio.set_determinants_mo_label 
      ;
    Ezfio.get_determinants_mo_label ()
    |> Non_empty_string.of_string
  ;;

  let read_n_det () =
    if not (Ezfio.has_determinants_n_det ()) then
      Ezfio.set_determinants_n_det 1
    ;
    Ezfio.get_determinants_n_det ()
    |> Det_number.of_int
  ;;

  let read_n_states () =
    if not (Ezfio.has_determinants_n_states ()) then
      Ezfio.set_determinants_n_states 1
    ;
    Ezfio.get_determinants_n_states ()
    |> States_number.of_int
  ;;

  let read_n_states_diag () =
    if not (Ezfio.has_determinants_n_states_diag ()) then
      read_n_states ()
      |> States_number.to_int
      |> Ezfio.set_determinants_n_states_diag 
    ;
    Ezfio.get_determinants_n_states_diag ()
    |> States_number.of_int
  ;;

  let read_n_det_max_jacobi () =
    if not (Ezfio.has_determinants_n_det_max_jacobi ()) then
      get_default "n_det_max_jacobi"
      |> Int.of_string
      |> Ezfio.set_determinants_n_det_max_jacobi 
    ;
    Ezfio.get_determinants_n_det_max_jacobi ()
    |> Det_number.of_int
  ;;

  let read_threshold_generators () =
    if not (Ezfio.has_determinants_threshold_generators ()) then
      get_default "threshold_generators"
      |> Float.of_string
      |> Ezfio.set_determinants_threshold_generators
    ;
    Ezfio.get_determinants_threshold_generators ()
    |> Threshold.of_float
  ;;

  let read_threshold_selectors () =
    if not (Ezfio.has_determinants_threshold_selectors ()) then
      get_default "threshold_selectors"
      |> Float.of_string
      |> Ezfio.set_determinants_threshold_selectors
    ;
    Ezfio.get_determinants_threshold_selectors ()
    |> Threshold.of_float
  ;;

  let read_read_wf () =
    if not (Ezfio.has_determinants_read_wf ()) then
      get_default "read_wf"
      |> Bool.of_string
      |> Ezfio.set_determinants_read_wf 
    ;
    Ezfio.get_determinants_read_wf ()
  ;;

  let read_expected_s2 () =
    if not (Ezfio.has_determinants_expected_s2 ()) then
      begin
        let na = Ezfio.get_electrons_elec_alpha_num ()
        and nb = Ezfio.get_electrons_elec_beta_num  ()
        in
        let s = 0.5 *. (Float.of_int (na - nb))
        in
        Ezfio.set_determinants_expected_s2 ( s *. (s +. 1.) )
      end
    ;
    Ezfio.get_determinants_expected_s2 ()
    |> Positive_float.of_float
  ;;

  let read_s2_eig () =
    if not (Ezfio.has_determinants_s2_eig ()) then
      get_default "s2_eig"
      |> Bool.of_string
      |> Ezfio.set_determinants_s2_eig
    ;
    Ezfio.get_determinants_s2_eig ()
  ;;

  let read_psi_coef () =
    if not (Ezfio.has_determinants_psi_coef ()) then
        Ezfio.ezfio_array_of_list ~rank:1 ~dim:[| 1 |] ~data:[1.]
        |> Ezfio.set_determinants_psi_coef 
      ;
    (Ezfio.get_determinants_psi_coef ()).Ezfio.data
    |> Ezfio.flattened_ezfio_data
    |> Array.map ~f:Det_coef.of_float
  ;;

  let read_psi_det () =
    let n_int = read_n_int () in
    if not (Ezfio.has_determinants_psi_det ()) then
      begin
        let rec build_data accu =  function
          | 0 -> accu
          | n -> build_data ((MO_number.of_int n)::accu) (n-1)
        in
        let det_a = build_data [] (Ezfio.get_electrons_elec_alpha_num ())
          |> Bitlist.of_mo_number_list n_int
        and det_b = build_data [] (Ezfio.get_electrons_elec_beta_num  ())
          |> Bitlist.of_mo_number_list n_int
        in
        let data = ( (Bitlist.to_int64_list det_a) @ 
          (Bitlist.to_int64_list det_b) ) 
        in
        Ezfio.ezfio_array_of_list ~rank:3 ~dim:[| N_int_number.to_int n_int ; 2 ; 1 |] ~data:data
        |> Ezfio.set_determinants_psi_det 
      end  ;
    let n_int = N_int_number.to_int n_int in
    let rec transform accu1 accu2 n_rest = function 
      | [] ->
          let accu1 = List.rev accu1
          |> Array.of_list 
          |> Determinant.of_int64_array
          in
          List.rev (accu1::accu2) |> Array.of_list
      | i::rest ->
          if (n_rest > 0) then
            transform (i::accu1) accu2 (n_rest-1) rest
          else
            let accu1 = List.rev accu1
            |> Array.of_list 
            |> Determinant.of_int64_array
            in
            transform [] (accu1::accu2) (2*n_int) rest
    in
    (Ezfio.get_determinants_psi_det ()).Ezfio.data
    |> Ezfio.flattened_ezfio_data
    |> Array.to_list
    |> transform [] [] (2*n_int)
  ;;

  let read () =
    { n_int                  = read_n_int ()                ;
      bit_kind               = read_bit_kind ()             ;
      mo_label               = read_mo_label ()             ;
      n_det                  = read_n_det ()                ;
      n_states               = read_n_states ()             ;
      n_states_diag          = read_n_states_diag ()        ;
      n_det_max_jacobi       = read_n_det_max_jacobi ()     ;
      threshold_generators   = read_threshold_generators () ;
      threshold_selectors    = read_threshold_selectors ()  ;
      read_wf                = read_read_wf ()              ;
      expected_s2            = read_expected_s2 ()          ;
      s2_eig                 = read_s2_eig ()               ;
      psi_coef               = read_psi_coef ()             ;
      psi_det                = read_psi_det ()              ;
    }
  ;;

  let to_string b =
    Printf.sprintf "
n_int                  = %s
bit_kind               = %s
mo_label               = \"%s\"
n_det                  = %s
n_states               = %s
n_states_diag          = %s
n_det_max_jacobi       = %s
threshold_generators   = %s
threshold_selectors    = %s
read_wf                = %s
expected_s2            = %s
s2_eig                 = %s
psi_coef               = %s
psi_det                = %s
"
     (b.n_int         |> N_int_number.to_string)
     (b.bit_kind      |> Bit_kind.to_string)
     (b.mo_label      |> Non_empty_string.to_string)
     (b.n_det         |> Det_number.to_string)
     (b.n_states      |> States_number.to_string)
     (b.n_states_diag |> States_number.to_string)
     (b.n_det_max_jacobi |> Det_number.to_string)
     (b.threshold_generators |> Threshold.to_string)
     (b.threshold_selectors |> Threshold.to_string)
     (b.read_wf       |> Bool.to_string)
     (b.expected_s2   |> Positive_float.to_string)
     (b.s2_eig        |> Bool.to_string)
     (b.psi_coef  |> Array.to_list |> List.map ~f:Det_coef.to_string
      |> String.concat ~sep:", ")
     (b.psi_det   |> Array.map ~f:(fun x -> Determinant.to_int64_array x
      |> Array.map ~f:(fun x-> 
          Int64.to_string x )|> Array.to_list |>
       String.concat ~sep:", ") |> Array.to_list
      |> String.concat ~sep:" | ")
     ;
;;

end


