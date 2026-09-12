open Ocaml_pricing_domain

(* Production snapshot and named A4 vectors match src/lib/core/pricing.test.ts.
   Expectations are TypeScript results, including known rounding failures.
   Missing format variants and APIs are documented in pricing-characterization.md. *)
let commission format base person complexity =
  Commission.create ~format ~base_price:(Money.of_cents base)
    ~additional_person_price:(Money.of_cents person)
    ~complexity_price:(Money.of_cents complexity)

let a4 = commission Commission.A4 14000 4500 3500
let percent n = Some (Discount.percent n)
let fixed n = Some (Discount.fixed (Money.of_cents n))

let vectors = [
  ("base", 1, false, [], None, 14000);
  ("two people", 2, false, [], None, 18500);
  ("three people", 3, false, [], None, 23000);
  ("complexity", 1, true, [], None, 17500);
  ("multiple adjustments", 1, false, [500; 1000], None, 15500);
  ("combined percent", 2, true, [500], percent 10, 20250);
  ("combined fixed", 2, true, [500], fixed 2000, 20500);
  ("percent zero", 1, false, [], percent 0, 14000);
  ("percent full", 1, false, [], percent 100, 0);
  ("fixed zero", 1, false, [], fixed 0, 14000);
  ("fixed full", 1, false, [], fixed 14000, 0);
  ("round below half", 1, false, [4], percent 10, 12604);
  ("round at half", 1, false, [5], percent 10, 12604);
  ("round above half", 1, false, [6], percent 10, 12605);
  ("round subtotal once", 1, false, [3; 3], percent 10, 12605);
 ]

let calculate commission people has_complexity adjustments discount =
  Pricing.calculate ~commission ~people ~has_complexity
    ~adjustments:(List.map Money.of_cents adjustments) ~discount
  |> Money.to_cents

let pricing_tests = List.map (fun (name, people, complexity, adjustments, discount, expected) ->
  Alcotest.test_case name `Quick (fun () ->
    Alcotest.check Alcotest.int "TypeScript cents" expected
      (calculate a4 people complexity adjustments discount))) vectors

let catalogue_tests = List.map (fun (name, format, base, person, complexity) ->
  Alcotest.test_case name `Quick (fun () ->
    Alcotest.check Alcotest.int "production base cents" base
      (calculate (commission format base person complexity) 1 false [] None))) [
  ("A6", Commission.A6, 5500, 2500, 1800);
  ("A5", Commission.A5, 9500, 3500, 2500);
  ("A4", Commission.A4, 14000, 4500, 3500);
  ("A3", Commission.A3, 23000, 7000, 5500);
 ]

let shipping_tests = List.map (fun (name, region, mode, expected) ->
  Alcotest.test_case name `Quick (fun () ->
    let shipping = Shipping.create ~region ~mode in
    Alcotest.check Alcotest.int "TypeScript shipping cents" expected
      (Money.to_cents (Shipping.price shipping ~default_price:(Money.of_cents 1500))))) [
  ("automatic DE", Shipping.Germany, Shipping.Automatic, 0);
  ("automatic EU", Shipping.European_union, Shipping.Automatic, 1500);
  ("manual override", Shipping.Germany, Shipping.Manual (Money.of_cents 700), 700);
  ("manual zero (helper behavior)", Shipping.European_union, Shipping.Manual Money.zero, 0);
]

let () = Alcotest.run "Production pricing characterization" [
  ("production catalogue subset", catalogue_tests);
  ("TypeScript commission vectors", pricing_tests);
  ("TypeScript shipping vectors", shipping_tests);
]
