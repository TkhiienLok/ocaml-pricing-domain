# Pricing characterization, 2026-09-10

Step 1 adds tests only. TypeScript production behavior is the reference; no
calculation, constructor, or validation rule has been changed.

## Matching vectors

`test/test_production_pricing.ml` pairs with the site's
`src/lib/core/pricing.test.ts` and `src/lib/shipping/getShippingPrice.test.ts`.
Both contain the same named A4 inputs and explicit TypeScript expectations.
Prices are integer EUR cents. A4 is 14000 base, 4500 per additional person,
3500 complexity. The catalogue subset also uses production A6, A5, A3 prices.
The TS catalogue assertions detect drift against the real configuration; update
both tables together after an intentional production price change.
The original synthetic OCaml tests remain intact.

## Expected failures, not accepted alternatives

The new OCaml suite deliberately asserts TypeScript results. It is expected to
fail until the implementation steps that follow this characterization:

| Case | TypeScript expected cents | Current OCaml cents |
| --- | ---: | ---: |
| round at half: A4 + 5 cents, 10% off | 12604 | 12605 |
| round above half: A4 + 6 cents, 10% off | 12605 | 12606 |
| round subtotal once: A4 + [3, 3] cents, 10% off | 12605 | 12606 |
| automatic DE with fallback 1500 | 0 | 1500 |

These are neither skipped tests nor assertions that the incorrect outputs are
acceptable. A failing parity suite is intentional at this tests-only step.

## Ambiguous inputs

The TS suites label these separately as current behavior, not a definition of
valid business inputs:

- Fractional percentages (12.5%) are accepted by TS but cannot be represented by
  OCaml's integer percent constructor. Decide the supported precision.
- Percentages above 100 and fixed discounts above the price yield negative TS
  results. OCaml rejects the former and clamps the latter. Decide whether to
  reject excessive fixed discounts at a boundary.
- Zero/negative people incur no TS addon; fractional people produce fractional
  addons. OCaml requires positive integer people. Document this stronger domain
  boundary rather than reproducing permissive inputs.
- Fractional fixed discounts and adjustments are accepted by TS; OCaml Money
  represents integer cents only. Decide the boundary policy.
- Manual shipping missing/zero produces zero in the helper, whereas the admin
  schema's truthiness validation rejects it. Negative and fractional manual
  amounts also reach the helper. The OCaml zero case records helper parity only.

## Explicit coverage limits

- OCaml cannot represent A8, mini-magnet, A7, square-medium, A5-sketchbook, US,
  Ukraine, or unknown/missing shipping regions. Their expectations are exercised
  on TS only; do not substitute another OCaml variant to claim coverage.
- OCaml exposes no standalone discount/shop or all-inclusive API. Those are TS
  characterization tests only. All-inclusive includes one person addon,
  complexity, and the maximum estimate adjustment; it is not a cart total.
- Currency display belongs to the TS presentation helper and has TS-only tests.
- Environment-dependent format availability and the optional test product are
  not production price vectors in this suite.
- Item quantities and once-per-order shipping are checkout composition, outside
  this unit-pricing step. Constructor and overflow tests belong to the following
  invariant implementation step.

## Commands

Site: `npm test -- --runInBand src/lib/core/pricing.test.ts src/lib/shipping/getShippingPrice.test.ts src/lib/formatPrice.test.ts`

OCaml: `dune runtest` (four expected new failures until parity fixes).
