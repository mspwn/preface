(** A [Monad] allow to sequences operations that are dependent from one to
    another, in contrast to {!module:Applicative}, which executes a series of
    independent actions.*)

(** {2 Laws}

    To have a predictable behaviour, the instance of [Bind] must obey some laws.

    + [(m >>= f) >>= g = m >>= (fun x +> f x >>= g)]
    + [join % join = join % (map join)]
    + [map id = id]
    + [map (g % f) = map g % map f]
    + [map f % join = join % map (map f)]
    + [map f % pure = pure % f]
    + [(f >=> g) >=> h = f >=> (g >=> h)] *)

(** {1 Minimal definition} *)

(** Minimal definition using [bind]. *)
module type WITH_BIND = sig
  type 'a t
  (** The type held by the [Monad]. *)

  val bind : ('a -> 'b t) -> 'a t -> 'b t
  (** [bind f m] passes the result of computation [m] to function [f]. *)
end

(** Minimal definition using [return], [map] and [join]. *)
module type WITH_MAP_AND_JOIN = sig
  type 'a t
  (** The type held by the [Monad]. *)

  val map : ('a -> 'b) -> 'a t -> 'b t
  (** Mapping over from ['a] to ['b] over ['a t] to ['b t]. *)

  val join : 'a t t -> 'a t
  (** [join] remove one level of monadic structure, projecting its bound
      argument into the outer level. *)
end

(** Minimal definition using [return] and [compose_left_to_right]. *)
module type WITH_KLEISLI_COMPOSITION = sig
  type 'a t
  (** The type held by the [Monad]. *)

  val compose_left_to_right : ('a -> 'b t) -> ('b -> 'c t) -> 'a -> 'c t
  (** Composing monadic functions using Kleisli Arrow (from left to right). *)
end

(** Minimal definition using [map] and [bind]. *)
module type WITH_MAP_AND_BIND = sig
  type 'a t
  (** The type held by the [Monad]. *)

  include Functor.WITH_MAP with type 'a t := 'a t
  include WITH_BIND with type 'a t := 'a t
end

(** Minimal definition using [map] and [compose_left_to_right]. *)
module type WITH_MAP_AND_KLEISLI_COMPOSITION = sig
  type 'a t
  (** The type held by the [Monad]. *)

  include Functor.WITH_MAP with type 'a t := 'a t
  include WITH_KLEISLI_COMPOSITION with type 'a t := 'a t
end

(** {1 Structure anatomy} *)

(** Basis operations. *)
module type CORE = sig
  include WITH_BIND
  (** @inline *)

  include WITH_MAP_AND_JOIN with type 'a t := 'a t
  (** @inline *)

  include WITH_KLEISLI_COMPOSITION with type 'a t := 'a t
  (** @inline *)
end

(** Additional operations. *)
module type OPERATION = sig
  type 'a t
  (** The type held by the [Monad]. *)

  val compose_right_to_left : ('b -> 'c t) -> ('a -> 'b t) -> 'a -> 'c t
  (** Composing monadic functions using Kleisli Arrow (from right to left). *)

  val lift : ('a -> 'b) -> 'a t -> 'b t
  (** Mapping over from ['a] to ['b] over ['a t] to ['b t]. *)

  val lift2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
  (** Mapping over from ['a] and ['b] to ['c] over ['a t] and ['b t] to ['c t]. *)

  val lift3 : ('a -> 'b -> 'c -> 'd) -> 'a t -> 'b t -> 'c t -> 'd t
  (** Mapping over from ['a] and ['b] and ['c] to ['d] over ['a t] and ['b t]
      and ['c t] to ['d t]. *)

  include Functor.OPERATION with type 'a t := 'a t
  (** @inline *)
end

(** Syntax extensions. *)
module type SYNTAX = sig
  type 'a t
  (** The type held by the [Monad]. *)

  val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
  (** Syntactic shortcuts for flipped version of {!val:CORE.bind}:

      [let* x = e in f] is equals to [bind (fun x -> f) e]. *)

  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  (** Syntactic shortcuts for flipped version of {!val:CORE.map}:

      [let+ x = e in f] is equals to [map (fun x -> f) e]. *)
end

(** Infix operators. *)
module type INFIX = sig
  type 'a t
  (** The type held by the [Monad]. *)

  val ( =|< ) : ('a -> 'b) -> 'a t -> 'b t
  (** Infix version of {!val:CORE.map}. *)

  val ( >|= ) : 'a t -> ('a -> 'b) -> 'b t
  (** Infix flipped version of {!val:CORE.map}. *)

  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
  (** Infix flipped version of {!val:CORE.bind}. *)

  val ( =<< ) : ('a -> 'b t) -> 'a t -> 'b t
  (** Infix version of {!val:CORE.bind}. *)

  val ( >=> ) : ('a -> 'b t) -> ('b -> 'c t) -> 'a -> 'c t
  (** Infix version of {!val:CORE.compose_left_to_right}. *)

  val ( <=< ) : ('b -> 'c t) -> ('a -> 'b t) -> 'a -> 'c t
  (** Infix version of {!val:OPERATION.compose_right_to_left}. *)

  val ( >> ) : unit t -> 'b t -> 'b t
  (** Sequentially compose two actions, discarding any value produced by the
      first. *)

  val ( << ) : 'a t -> unit t -> 'a t
  (** Sequentially compose two actions, discarding any value produced by the
      second. *)

  include Functor.INFIX with type 'a t := 'a t
  (** @inline *)
end

(** {1 Complete API} *)

(** The complete interface of a [Monad]. *)
module type API = sig
  (** {1 Type} *)

  type 'a t
  (** The type held by the [Monad]. *)

  (** {1 Functions} *)

  include CORE with type 'a t := 'a t
  (** @inline *)

  include OPERATION with type 'a t := 'a t
  (** @inline *)

  (** {1 Infix operators} *)

  module Infix : INFIX with type 'a t = 'a t

  include INFIX with type 'a t := 'a t
  (** @inline *)

  (** {1 Syntax} *)

  module Syntax : SYNTAX with type 'a t = 'a t

  include SYNTAX with type 'a t := 'a t
  (** @inline *)
end

(** {1 Additional references}

    - {{:https://hackage.haskell.org/package/semigroupoids-5.3.6/docs/Data-Functor-Bind.html}
      Haskell's documentation of Bind} *)
