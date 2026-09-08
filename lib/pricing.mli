val calculate :
  commission:Commission.t ->
  people:int ->
  has_complexity:bool ->
  adjustments:Money.t list ->
  discount:Discount.t option ->
  Money.t