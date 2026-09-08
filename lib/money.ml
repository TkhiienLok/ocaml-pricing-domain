type t = int

let zero = 0

let of_cents value =
  if value < 0 then
    invalid_arg "Money cannot be negative"
  else
    value

let to_cents value = value

let add a b =
  a + b

let subtract a b =
  max 0 (a - b)

let multiply money amount =
  if amount < 0 then
    invalid_arg "Amount cannot be negative"
  else
    money * amount