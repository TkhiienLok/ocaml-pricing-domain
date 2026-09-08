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

This repository is an engineering experiment and is not used
by the production checkout.

## Architecture

Current:

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
        └── Pricing
             |
             v
          Unit tests

## Next phase

Expose the pricing domain through a small HTTP service and
compare its result against the existing TypeScript pricing
implementation before considering any production migration.
