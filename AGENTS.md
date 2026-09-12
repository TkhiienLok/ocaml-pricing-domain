# OCaml Pricing Domain — Agent Instructions

## Project purpose

This repository implements the pricing domain of an existing Next.js / TypeScript application in OCaml.

The immediate goal is not to redesign the business rules.

The goal is to:

1. understand the existing TypeScript pricing behaviour,
2. reproduce that behaviour faithfully in OCaml,
3. model the domain more safely using OCaml's type system,
4. prevent invalid domain states where practical,
5. create strong automated tests demonstrating behavioural parity between the TypeScript and OCaml implementations.

This OCaml package may later become part of a larger developer content-management / content-pipeline system, so prefer a small, clean, reusable domain library rather than code tied to a CLI, HTTP server, database, or UI.

---

## Workspace boundaries

This VS Code workspace intentionally contains only the repositories relevant to this task.

There are two relevant codebases:

### 1. OCaml pricing domain

This repository is the primary implementation target.

You may:

* inspect all files in this repository, except ignore/ folder,
* modify OCaml source files,
* modify Dune / OPAM configuration when necessary,
* add or improve tests,
* add domain documentation.

### 2. Existing Next.js / TypeScript application

This repository contains the current production pricing implementation.

Treat its pricing logic as the behavioural reference implementation.

You may:

* read pricing-related production code,
* trace types and helpers required to understand pricing behaviour,
* inspect existing pricing tests,
* add or improve TypeScript pricing tests where useful for establishing expected behaviour.

Do NOT:

* refactor unrelated Next.js code,
* change UI code,
* change production TypeScript pricing behaviour merely to make the OCaml version easier to implement,
* inspect unrelated repositories, personal directories, or files outside the folders explicitly included in this workspace.

If information outside these workspace folders appears potentially useful, ask before accessing it.

---

## TypeScript source of truth

The existing TypeScript implementation is the source of truth for valid-input pricing behaviour unless documentation explicitly states otherwise.

Before changing the OCaml implementation:

1. identify all TypeScript functions involved in pricing,
2. identify the relevant domain types,
3. follow helper functions used by those calculations,
4. identify rounding rules, discounts, quantities, format-specific rules, optional values, and edge cases,
5. inspect existing tests,
6. write down any observable behaviour that is ambiguous.

Primary TypeScript pricing files:

* `graphite-portraits-shop/graphite-portrait-site/src/lib/core/pricing.ts`
* `graphite-portraits-shop/src/config/commissions.ts`
* `graphite-portraits-shop/src/config/shippingRegions.ts`
* `graphite-portraits-shop/src/lib/shipping/getShippingPrice.ts`
* `graphite-portraits-shop/src/lib/formatPrice.ts`

Follow imports from these files only when necessary to understand pricing behaviour.

Do not scan unrelated application areas.

---

## Existing project documentation

Read the existing MVP/project notes before making architectural changes.

Primary project notes:

* `graphite-portraits-shop/graphite-portrait-site/docs/mvp-content-preparation-automation.md`

Treat these notes as product and architecture context, but verify concrete pricing behaviour against the existing TypeScript implementation.

If the notes conflict with actual TypeScript behaviour, report the discrepancy rather than silently choosing one.

---

## Domain modelling goals

The OCaml implementation should expose a domain model that makes invalid states difficult or impossible to construct.

Prefer domain-specific types and validated constructors over raw primitives when the distinction carries business meaning.

In particular, investigate whether the model should protect invariants such as:

* quantities must not be negative,
* counts must not be negative,
* percentages must stay within their valid range,
* discounts must not exceed the allowed domain range,
* monetary values should not accidentally mix incompatible representations,
* unsupported pricing formats should not be representable as arbitrary strings,
* impossible combinations of pricing options should not be constructible,
* validation should happen at domain boundaries rather than being scattered through calculation functions.

Do not over-engineer trivial values solely for the sake of creating more types.

Use types where they remove meaningful classes of invalid states.

For values that cannot be fully constrained by the OCaml type system, expose validated constructors returning an appropriate `result` or option-like type rather than relying on unchecked conventions.

---

## Behavioural parity

For valid business inputs, the OCaml implementation should produce the same pricing results as the existing TypeScript implementation.

Do not assume that the current OCaml implementation is already correct.

Compare the implementations function by function.

Produce a mapping such as:

TypeScript function → OCaml function → parity status → relevant tests

Check especially:

* base-price calculation,
* format-specific pricing,
* quantities,
* discounts,
* optional modifiers,
* rounding,
* integer vs floating-point behaviour,
* boundary conditions,
* composition of multiple pricing rules.

If behaviour differs, determine whether the difference is:

1. an OCaml implementation bug,
2. an intentional stronger OCaml invariant,
3. ambiguous existing TypeScript behaviour,
4. a likely TypeScript bug.

Do not silently change business behaviour when the correct interpretation is uncertain.

---

## Testing strategy

Tests are a first-class part of this project.

The test suite should cover both ordinary examples and domain boundaries.

Add OCaml tests for:

* normal pricing examples,
* minimum and maximum relevant values,
* zero values where allowed,
* discounts at important boundaries,
* invalid constructor inputs,
* format-specific calculations,
* rounding-sensitive cases,
* previously discovered mismatches.

Also improve the TypeScript pricing tests where coverage is insufficient.

Where practical, use the same explicit test vectors for both languages so that equivalent inputs and expected outputs are easy to compare.

A test vector should make the business rule obvious rather than depending on UI behaviour.

Do not weaken a test simply to make an implementation pass.

---

## Important distinction: parity vs invariants

Behavioural parity applies to valid inputs.

The OCaml API is allowed — and encouraged — to reject invalid states that the TypeScript implementation could technically construct because of weaker runtime/domain constraints.

For example, if TypeScript can structurally represent a negative quantity but the business domain says quantities cannot be negative, the OCaml implementation should not reproduce that weakness merely for parity.

Document such intentional differences.

---

## Implementation style

Prefer:

* pure functions,
* explicit domain types,
* small modules with clear responsibilities,
* exhaustive pattern matching,
* immutable values,
* descriptive variant types,
* validated constructors,
* `result` for meaningful validation failures,
* tests close to domain behaviour.

Avoid:

* exceptions for ordinary validation,
* mutable state unless genuinely necessary,
* framework-specific abstractions,
* premature persistence or networking concerns,
* generic abstractions that obscure pricing rules,
* copying TypeScript structure mechanically when OCaml can express the domain more safely.

Use Jane Street `Base` only if it provides a concrete benefit to this project. Do not introduce it merely because it is common in OCaml projects.

---

## Current scope

The current task is the pricing domain only.

Do not yet implement:

* the future content-management pipeline,
* CMS integration,
* publishing automation,
* GitHub automation,
* Next.js content generation,
* network services,
* databases,
* queues,
* deployment infrastructure.

The pricing library should, however, remain reusable by such a system later.

---

## Workflow for this repository

Before making substantial changes:

1. inspect the TypeScript pricing implementation,
2. inspect the current OCaml implementation,
3. inspect both test suites,
4. produce a concise parity assessment,
5. identify missing invariants and unsafe representations.

Then implement the improvements.

After changes:

1. run the OCaml tests,
2. run the relevant TypeScript tests,
3. run formatting/type checks relevant to changed files,
4. report remaining behavioural differences,
5. summarize which invalid states are now prevented by the OCaml API.

Do not claim parity unless tests demonstrate it.

---

## Definition of done for the current milestone

The milestone is complete when:

* the relevant TypeScript pricing behaviour has been mapped,
* the OCaml implementation matches valid-input behaviour,
* important domain invariants are represented explicitly,
* invalid inputs cannot silently enter core calculations where reasonably preventable,
* OCaml tests cover normal and boundary behaviour,
* TypeScript tests provide comparable coverage,
* both relevant test suites pass,
* intentional differences between TypeScript and OCaml are documented,
* the OCaml pricing package remains independent from the future content-management implementation.
