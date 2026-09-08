let calculate_people_price commission people =
  if people < 1 then
    invalid_arg "A commission must contain at least one person";

  let additional_people = people - 1 in

  Money.multiply
    (Commission.additional_person_price commission)
    additional_people


let calculate_complexity_price commission has_complexity =
  if has_complexity then
    Commission.complexity_price commission
  else
    Money.zero


let calculate_adjustments adjustments =
  List.fold_left
    Money.add
    Money.zero
    adjustments


let apply_discount price discount =
  match discount with
  | None ->
      price

  | Some (Discount.Fixed amount) ->
      Money.subtract price amount

  | Some (Discount.Percent percent) ->
      let cents =
        Money.to_cents price
      in

      let discount_amount =
        (cents * percent) / 100
      in

      Money.of_cents
        (cents - discount_amount)


let calculate
    ~commission
    ~people
    ~has_complexity
    ~adjustments
    ~discount =

  let base_price =
    Commission.base_price commission
  in

  let people_price =
    calculate_people_price
      commission
      people
  in

  let complexity_price =
    calculate_complexity_price
      commission
      has_complexity
  in

  let adjustment_price =
    calculate_adjustments adjustments
  in

  let subtotal =
    base_price
    |> Money.add people_price
    |> Money.add complexity_price
    |> Money.add adjustment_price
  in

  apply_discount subtotal discount