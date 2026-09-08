type region =
  | Germany
  | European_union

type mode =
  | Automatic
  | Manual of Money.t

type t = {
  region : region;
  mode : mode;
}

let create ~region ~mode =
  {
    region;
    mode;
  }

let region shipping =
  shipping.region

let mode shipping =
  shipping.mode

let price shipping ~default_price =
  match shipping.mode with
  | Automatic ->
      default_price
  | Manual amount ->
      amount