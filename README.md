# OCaml Pricing Domain

A small domain-modelling experiment based on pricing rules
from my portrait commission application.

The production application currently implements these rules
in TypeScript. This project explores how the same domain can
be represented using OCaml's algebraic data types, modules
and pure functions.

## Goals

- model monetary values explicitly in cents
- make invalid pricing states harder to represent
- isolate pricing rules as pure functions
- cover pricing behaviour with unit tests
- establish behavioural parity with the TypeScript implementation
- explore a future HTTP boundary between a Next.js
  application and an OCaml pricing service

## Current scope

The first iteration models:

- portrait formats
- base prices
- additional-person pricing
- complexity surcharges
- additional adjustments
- fixed discounts
- percentage discounts
- shipping regions and automatic/manual shipping modes (partial implementation)

This repository is an engineering experiment and is not used
by the production checkout. Behavioural parity is not yet complete.

## Architecture

```text
TypeScript application
        |
        | existing production pricing
        v
Production checkout

OCaml Pricing Domain
        |
        ├── Money
        ├── Commission
        ├── Discount
        ├── Shipping
        └── Pricing
             |
             v
          Unit tests
```

## Testing

With the project dependencies and Alcotest installed in the active OPAM switch,
run from this repository:

```sh
opam exec -- dune runtest
```

The suite includes the original synthetic pricing examples and production-price
characterization vectors matching the TypeScript tests. The TypeScript
implementation supplies the expected pricing results.

At the characterization stage, seven original tests and 19 new vectors pass.
Four new tests fail: three percentage-rounding cases and automatic shipping to
Germany. These failures expose existing implementation gaps; the tests retain
the TypeScript expectations until the OCaml fixes are implemented.

See [Pricing characterization](docs/pricing-characterization.md) for the matching
vectors, known mismatches, ambiguous inputs, coverage limits, and TypeScript test
command.

## Next phase

Fix the known rounding and shipping mismatches, complete the missing pricing
behaviour, and strengthen domain invariants with validated boundaries. Use the
characterization vectors to verify parity, and document intentional differences
for invalid inputs and decisions about ambiguous business rules.

A small HTTP service remains a later possibility for comparing the OCaml domain
with the production application before considering any migration. The immediate
focus is the reusable pricing library and its tests.
