open Ocaml_pricing_domain


let money =
  Alcotest.testable
    (fun formatter value ->
      Format.fprintf
        formatter
        "%d cents"
        (Money.to_cents value))
    (fun a b ->
      Money.to_cents a = Money.to_cents b)


let commission =
  Commission.create
    ~format:Commission.A4
    ~base_price:(Money.of_cents 12000)
    ~additional_person_price:(Money.of_cents 3500)
    ~complexity_price:(Money.of_cents 2000)


let test_base_price () =
  let price =
    Pricing.calculate
      ~commission
      ~people:1
      ~has_complexity:false
      ~adjustments:[]
      ~discount:None
  in

  Alcotest.check
    money
    "base price"
    (Money.of_cents 12000)
    price


let test_additional_person () =
  let price =
    Pricing.calculate
      ~commission
      ~people:2
      ~has_complexity:false
      ~adjustments:[]
      ~discount:None
  in

  Alcotest.check
    money
    "additional person"
    (Money.of_cents 15500)
    price


let test_complexity () =
  let price =
    Pricing.calculate
      ~commission
      ~people:1
      ~has_complexity:true
      ~adjustments:[]
      ~discount:None
  in

  Alcotest.check
    money
    "complexity surcharge"
    (Money.of_cents 14000)
    price


let test_adjustment () =
  let price =
    Pricing.calculate
      ~commission
      ~people:1
      ~has_complexity:false
      ~adjustments:[
        Money.of_cents 500;
        Money.of_cents 1000;
      ]
      ~discount:None
  in

  Alcotest.check
    money
    "additional adjustments"
    (Money.of_cents 13500)
    price


let test_percentage_discount () =
  let price =
    Pricing.calculate
      ~commission
      ~people:1
      ~has_complexity:false
      ~adjustments:[]
      ~discount:(
        Some (Discount.percent 10)
      )
  in

  Alcotest.check
    money
    "10 percent discount"
    (Money.of_cents 10800)
    price


let test_fixed_discount () =
  let price =
    Pricing.calculate
      ~commission
      ~people:1
      ~has_complexity:false
      ~adjustments:[]
      ~discount:(
        Some (
          Discount.fixed
            (Money.of_cents 2000)
        )
      )
  in

  Alcotest.check
    money
    "fixed discount"
    (Money.of_cents 10000)
    price


let test_combined_price () =
  let price =
    Pricing.calculate
      ~commission
      ~people:2
      ~has_complexity:true
      ~adjustments:[
        Money.of_cents 500;
      ]
      ~discount:(
        Some (Discount.percent 10)
      )
  in

  (*
     12000 base
     + 3500 additional person
     + 2000 complexity
     + 500 adjustment
     = 18000

     10% discount = 1800

     final = 16200
  *)

  Alcotest.check
    money
    "combined pricing rules"
    (Money.of_cents 16200)
    price


let () =
  Alcotest.run
    "OCaml Pricing Domain"
    [
      (
        "pricing",
        [
          Alcotest.test_case
            "base price"
            `Quick
            test_base_price;

          Alcotest.test_case
            "additional person"
            `Quick
            test_additional_person;

          Alcotest.test_case
            "complexity surcharge"
            `Quick
            test_complexity;

          Alcotest.test_case
            "adjustments"
            `Quick
            test_adjustment;

          Alcotest.test_case
            "percentage discount"
            `Quick
            test_percentage_discount;

          Alcotest.test_case
            "fixed discount"
            `Quick
            test_fixed_discount;

          Alcotest.test_case
            "combined pricing"
            `Quick
            test_combined_price;
        ]
      );
    ]