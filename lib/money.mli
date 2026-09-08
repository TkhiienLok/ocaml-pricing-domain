type t

val zero : t

val of_cents : int -> t
val to_cents : t -> int

val add : t -> t -> t
val subtract : t -> t -> t
val multiply : t -> int -> t