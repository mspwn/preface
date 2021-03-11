module Via_dimap (Core : Preface_specs.Profunctor.CORE_WITH_DIMAP) :
  Preface_specs.PROFUNCTOR with type ('a, 'b) t = ('a, 'b) Core.t = struct
  include Core

  let contramap_fst f x = Core.dimap f Fun.id x

  let map_snd f x = Core.dimap Fun.id f x
end

module Via_contramap_fst_and_map_snd
    (Core : Preface_specs.Profunctor.CORE_WITH_CONTRAMAP_FST_AND_MAP_SND) :
  Preface_specs.PROFUNCTOR with type ('a, 'b) t = ('a, 'b) Core.t = struct
  include Core

  let dimap f g x = contramap_fst f (map_snd g x)
end

module From_monad (Monad : Preface_specs.Monad.CORE) :
  Preface_specs.PROFUNCTOR with type ('a, 'b) t = 'a -> 'b Monad.t = struct
  type ('a, 'b) t = 'a -> 'b Monad.t

  open Preface_core.Fun.Infix

  let dimap f g h = Monad.map g % h % f

  let contramap_fst k f = f % k

  let map_snd k f = Monad.map k % f
end
