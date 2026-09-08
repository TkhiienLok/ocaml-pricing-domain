type t =
  | Fixed of Money.t
  | Percent of int

let fixed amount =
  Fixed amount

let percent value =
  if value < 0 || value > 100 then
    invalid_arg "Discount percentage must be between 0 and 100"
  else
    Percent value