# Phase 1 можно закончить именно здесь

И вот здесь уже можно делать Engineering Lab entry.

Не надо ждать HTTP API.

У тебя уже будут:

- реальный домен;
- OCaml modules;
- ADTs;
- opaque Money.t;
- pure functions;
- unit tests;
- comparison with production TypeScript;
- architectural next step.

Это уже содержательный experiment.

# Phase 2: маленький OCaml HTTP service

А потом уже можно добавить:

```text
bin/
├── dune
└── server.ml
```

и endpoint вроде:

```
POST /pricing/calculate
```

Request:

```
{
  "format": "a4",
  "people": 2,
  "complexity": true,
  "adjustmentsInCents": [500],
  "discount": {
    "type": "percent",
    "value": 10
  }
}
```
Response:

```
{
  "priceInCents": 16650
}
```

Но JSON parsing должен быть boundary code, а твой Pricing.calculate вообще не должен знать, что существует HTTP или JSON.

Архитектурно:

```
HTTP
 ↓
JSON decoder
 ↓
Validated domain values
 ↓
Pricing.calculate
 ↓
Money.t
 ↓
JSON response
```
Вот это очень хорошая illustration для Engineering Lab.

# Phase 3: Vercel

И да — то, что мы обсуждали раньше, теперь реально поддерживается Vercel: с 30 июня 2026 Vercel Functions умеют запускать OCI-containerized HTTP servers из Dockerfile.vercel / Containerfile.vercel. Сервер должен слушать $PORT. Это позволяет размещать backend на языке, для которого нет обычного Vercel runtime, включая OCaml.

То есть потенциальная схема совершенно реалистичная:

```
┌──────────────────────────────┐
│ Lok Chan Art / Next.js       │
│                              │
│ Checkout / commission form   │
└──────────────┬───────────────┘
               │
               │ HTTPS
               ▼
┌──────────────────────────────┐
│ OCaml Pricing Service        │
│ Vercel Container Function    │
│                              │
│ HTTP boundary                │
│        ↓                     │
│ Pricing Domain               │
│ Money · Commission · Discount│
└──────────────┬───────────────┘
               │
               ▼
        priceInCents
```
И внутри deployment:

```
GitHub
  ↓
Vercel
  ↓
Dockerfile.vercel
  ↓
Build OCaml executable
  ↓
OCI container
  ↓
HTTP server listening on $PORT
```

Vercel container functions при этом stateless, поэтому pricing calculation — практически идеальный демонстрационный workload для такой архитектуры: request → pure computation → response, без необходимости хранить локальное состояние.

Но я бы сделала ещё интереснее: shadow verification

Это, по-моему, сильнейшая часть будущего case study.

Не:

```
OLD TS OUT
OCAML IN
```

А:

```
                 ┌── TypeScript Pricing ──→ €155.00
Checkout input ──┤
                 └── OCaml Pricing ───────→ €155.00
                              │
                              ▼
                       Compare results
```

На первой стадии TypeScript остаётся authoritative:

```
TS result → customer checkout
OCaml result → comparison/logging only
```

Если результаты расходятся:

```
expected: 15500
ocaml:    15499
```

ты находишь различия в rounding/business rules.

Это уже очень senior-looking migration story: не «переписала на модный язык», а parallel verification before changing the source of truth.

Что поставить в Engineering Lab

Я бы назвала саму карточку:

Pricing Domain Modelling in OCaml

Подзаголовок:

```
OCaml · Domain Modelling · Functional Programming · Testing · 2026
```

Короткий intro:

I used pricing rules from my portrait commission application
as a small domain-modelling experiment in OCaml.

The existing production implementation is written in TypeScript.
Rather than translating it line by line, I am exploring how
OCaml's type system and modules can move some pricing guarantees
from runtime validation into the domain model itself.

Потом три маленьких раздела:

### Current Experiment

- monetary values represented explicitly in cents
- algebraic data types for pricing rules
- pure pricing calculations
- invalid states constrained at the domain boundary
- unit tests for pricing behaviour

### Why OCaml?

The goal is not to replace TypeScript because of performance.
The experiment focuses on domain modelling, explicit state,
type safety and testability.

### Next Step

Expose the domain as a small containerized HTTP service and
run it alongside the existing TypeScript pricing calculation
for parallel verification.

Это очень важно: не performance. Если на interview тебя спросят «зачем network service для сложения нескольких чисел?», твой ответ уже встроен в case study: это experiment в modelling/interoperability/safe migration, не попытка оптимизировать 0.2 ms calculation.

А LinkedIn post первой фазы я бы строила вокруг одного конкретного наблюдения

Не:

I'm learning OCaml! 🎉

А что-то вроде:

I stopped using toy exercises to learn OCaml and gave it a piece of a real domain instead.

Дальше:

My portrait commission application already has real pricing
rules implemented in TypeScript: base prices, additional people,
complexity adjustments, shipping and discounts.

I have been learning OCaml, so I started modelling a subset
of that domain rather than building another standalone exercise.

The interesting part isn't syntax.

It's deciding which states the program should be able to
represent at all.

Потом пример:

```
type discount =
  | Fixed of Money.t
  | Percent of int
```

И:

A discount cannot accidentally be both fixed and percentage-based, or neither, once it has crossed the domain boundary.

Потом tests/GitHub link/architecture image.

Это уже выглядит как публикация инженера, а не update о прохождении курса.

И я бы для первого вечера поставила себе очень конкретный definition of done: repository создан → Money, Commission, Discount, Pricing → минимум 6 passing Alcotest tests → README → GitHub push. Всё остальное — HTTP, Docker/Vercel, comparison mode и статья — уже следующие commits. Это достаточно маленький scope, чтобы реально закончить, но результат уже можно показать.