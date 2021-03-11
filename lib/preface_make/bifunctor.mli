(** {1 Documentation} *)

(** {2 Construction}

    Standard way to build a [Bifunctor]. *)

(** Incarnation of a [Bifunctor] with [bimap]. *)
module Via_bimap (Core : Preface_specs.Bifunctor.CORE_WITH_BIMAP) :
  Preface_specs.BIFUNCTOR with type ('a, 'b) t = ('a, 'b) Core.t

(** Incarnation of a [Bifunctor] with [map_fst] and [map_snd]. *)
module Via_map_fst_and_map_snd
    (Core : Preface_specs.Bifunctor.CORE_WITH_MAP_FST_AND_MAP_SND) :
  Preface_specs.BIFUNCTOR with type ('a, 'b) t = ('a, 'b) Core.t

(** {2 Manual construction}

    Advanced way to build a [Bifunctor], constructing and assembling a
    component-by-component a bifunctor. (In order to provide your own
    implementation for some features.) *)

(** Incarnation of a [Bifunctor] using each components of a [Bifunctor]. *)
module Via
    (Core : Preface_specs.Bifunctor.CORE)
    (Operation : Preface_specs.Bifunctor.OPERATION
                   with type ('a, 'b) t = ('a, 'b) Core.t) :
  Preface_specs.BIFUNCTOR with type ('a, 'b) t = ('a, 'b) Core.t

(** Incarnation of a [Bifunctor.Core] with [bimap]. *)
module Core_via_bimap (Core : Preface_specs.Bifunctor.CORE_WITH_BIMAP) :
  Preface_specs.Bifunctor.CORE with type ('a, 'b) t = ('a, 'b) Core.t

(** Incarnation of a [Bifunctor.Core] with [map_fst] and [map_snd]. *)
module Core_via_map_fst_and_map_snd
    (Core : Preface_specs.Bifunctor.CORE_WITH_MAP_FST_AND_MAP_SND) :
  Preface_specs.Bifunctor.CORE with type ('a, 'b) t = ('a, 'b) Core.t

(** Incarnation of a [Bifunctor.Operation] with [Bifunctor.Core]. *)
module Operation (Core : Preface_specs.Bifunctor.CORE) :
  Preface_specs.Bifunctor.OPERATION with type ('a, 'b) t = ('a, 'b) Core.t
