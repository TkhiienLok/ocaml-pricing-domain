type region =
  | Germany
  | European_union

type mode =
  | Automatic
  | Manual of Money.t

type t

val create :
  region:region ->
  mode:mode ->
  t

val region : t -> region
val mode : t -> mode

val price :
  t ->
  default_price:Money.t ->
  Money.t