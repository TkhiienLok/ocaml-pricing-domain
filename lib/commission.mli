type format =
  | A6
  | A5
  | A4
  | A3

type t

val create :
  format:format ->
  base_price:Money.t ->
  additional_person_price:Money.t ->
  complexity_price:Money.t ->
  t

val format : t -> format
val base_price : t -> Money.t
val additional_person_price : t -> Money.t
val complexity_price : t -> Money.t