type format =
  | A6
  | A5
  | A4
  | A3

type t = {
  format : format;
  base_price : Money.t;
  additional_person_price : Money.t;
  complexity_price : Money.t;
}

let create
    ~format
    ~base_price
    ~additional_person_price
    ~complexity_price =
  {
    format;
    base_price;
    additional_person_price;
    complexity_price;
  }

let format commission =
  commission.format

let base_price commission =
  commission.base_price

let additional_person_price commission =
  commission.additional_person_price

let complexity_price commission =
  commission.complexity_price