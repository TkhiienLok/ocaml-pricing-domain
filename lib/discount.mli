type t = private
  | Fixed of Money.t
  | Percent of int

val fixed : Money.t -> t
val percent : int -> t