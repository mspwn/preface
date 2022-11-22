module type LAWS = sig
  module Foldable : Preface_specs.FOLDABLE

  val foldable_1 :
       unit
    -> ( (module Preface_specs.Types.T0 with type t = 'a)
       , ('b -> 'a -> 'a) -> 'a -> 'b Foldable.t -> 'a )
       Law.t

  val foldable_2 :
       unit
    -> ( (module Preface_specs.Types.T0 with type t = 'a)
       , ('a -> 'b -> 'a) -> 'a -> 'b Foldable.t -> 'a )
       Law.t

  val foldable_3 :
       unit
    -> ( (module Preface_specs.MONOID with type t = 'a)
       , 'a Foldable.t -> 'a )
       Law.t
end

module For (F : Preface_specs.FOLDABLE) : LAWS with module Foldable := F =
struct
  open Law

  let foldable_1 () =
    let lhs (type a) (module _ : Preface_specs.Types.T0 with type t = a) f z x =
      F.(fold_right f x z)
    and rhs (type a) (module T : Preface_specs.Types.T0 with type t = a) f z x =
      let module E = Util.Endo (T) in
      (F.fold_map (module E) f x) z
    in

    law
      ~lhs:("fold_right f x z" =~ lhs)
      ~rhs:("(fold_map (module Endo) f x) z" =~ rhs)
  ;;

  let foldable_2 () =
    let lhs (type a) (module _ : Preface_specs.Types.T0 with type t = a) f z x =
      F.(fold_left f z x)
    and rhs (type a) (module T : Preface_specs.Types.T0 with type t = a) f z x =
      let module E = Util.Endo (T) in
      let module D = Util.Dual (E) in
      let t = Fun.flip f in
      (F.fold_map (module D) t x) z
    in

    law ~lhs:("fold_left f z x" =~ lhs)
      ~rhs:("(fold_map (module Dual(Endo)) (Fun.flip f) x) z" =~ rhs)
  ;;

  let foldable_3 () =
    let lhs (type a) (module M : Preface_specs.MONOID with type t = a) x =
      F.reduce (module M) x
    and rhs (type a) (module M : Preface_specs.MONOID with type t = a) x =
      F.fold_map (module M) (fun x -> x) x
    in

    law ~lhs:("reduce (module M)" =~ lhs) ~rhs:("fold_map (module M) id" =~ rhs)
  ;;
end
