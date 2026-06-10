# DBT_PIPELINE.md — pipeline walkthrough

> Companion depth-doc for the dbt build. The README gives the project overview;
> this file explains how the pipeline works layer by layer and why each design
> decision was taken. Written for a reviewer who wants to follow the data from
> raw AdventureWorks tables to the published Tableau workbook.

---

## Pipeline at a glance

```
AdventureWorks OLTP (local PostgreSQL, native schemas)
        │  13 source tables declared in dbt (purchasing / production / sales)
        ▼
Staging layer — 13 views (stg_*), 1:1 with sources
        │  rename to snake_case, light DATE recasts, no business logic
        ▼
Marts layer — 8-table star (analytics schema)
        │  4 dims + 4 facts, hashed surrogate keys, referential-integrity tests
        │  fct_stock_movements is INCREMENTAL (delete+insert)
        ▼
Snapshot — snap_product_list_price (SCD2 over dated price changes)
        ▼
CSV export — sql/export/01_export_marts_to_csv.sql → tableau/data/*.csv
        ▼
Tableau Public — one workbook, three dashboards, star rebuilt on surrogate keys
```

Full `dbt build` = **155 PASS / 0 ERROR** (22 nodes + 133 data tests).

## 1. Source layer

All 13 raw tables are declared in
`adventureworks_ops/models/staging/_adventureworks__sources.yml`, one dbt source
per Postgres schema (purchasing / production / sales) because dbt scopes a
source to a single schema. The data loads into AdventureWorks' native schemas —
there is no artificial `raw` schema rename.

- Built-in tests only at this layer (`not_null`, `unique`, `relationships`):
  they establish the inbound → warehouse → outbound referential chain and act
  as the source-quality gate.
- Source freshness is deliberately NOT configured: the dataset is a static
  historical load (newest dates ~2014), so a freshness check would always
  report stale and tell us nothing. A commented example is left on
  `transactionhistory` to show the technique.
- Test arguments use the dbt 1.11 `arguments:` nesting (top-level test kwargs
  are deprecated).

## 2. Staging layer

Thirteen views, exactly one per source table, named
`stg_<schema>__<table>`. Each follows the same two-CTE shape (`source` →
`renamed`) and does only mechanical work: snake_case renames, `::DATE` recasts
on timestamp columns that are semantically dates, and dropping `rowguid`-style
noise. No joins, no business logic — that belongs to the marts.

Composite-grain staging models (`product_vendor`, `product_inventory`,
`price_history`) carry `dbt_utils.unique_combination_of_columns` tests because
no single column is unique at their grain.

## 3. Marts — the 8-table star

| Model | Grain |
| --- | --- |
| dim_product | one product / SKU |
| dim_vendor | one supplier |
| dim_customer | one customer |
| dim_location | one warehouse zone |
| fct_sales_order_lines | one outbound sales-order line (121,317) |
| fct_purchase_order_lines | one inbound PO line (8,845) |
| fct_stock_movements | one stock-movement ledger entry (202,696) |
| fct_product_inventory | on-hand qty per (product, location) (1,069) |

- Surrogate keys are hashed with `dbt_utils.generate_surrogate_key` on the
  natural key(s); star integrity is enforced with `relationships` tests from
  every fact FK to its dimension.
- All models land in a single `analytics` schema — layers are distinguished by
  name prefix (`stg_` / `dim_` / `fct_`), not by schema, which avoids dbt's
  target-schema concatenation behaviour on Postgres.
- Staging materializes as views, marts as tables (set per-folder in
  `dbt_project.yml`).

## 4. dbt depth — the lead theme

### Reusable macro

`macros/extended_amount.sql` centralises the line-amount rule
(qty × price, with an optional discount factor). It is used for
`gross_amount` / `net_amount` on fct_sales_order_lines and `line_amount` on
fct_purchase_order_lines, replacing three hand-written copies of the same
arithmetic. The compiled SQL is identical to the originals — verified by
rebuilding and comparing fact values.

### Custom generic tests (authored from scratch)

In `adventureworks_ops/tests/generic/`:

- `not_negative` — fails if any value in the column is < 0. Applied to nine
  quantity/money columns across the two line facts.
- `at_or_below_column` — fails if a column exceeds a comparison column on the
  same row. Applied as net_amount ≤ gross_amount on sales lines.

Both take their arguments via the dbt 1.11 `arguments:` property.

### Test packages

Pinned in `packages.yml`: `dbt-labs/dbt_utils 1.3.3`,
`metaplane/dbt_expectations 0.10.10` (the canonical namespace — the old
calogica path is stale) and its only dependency `godatadriven/dbt_date`.
dbt-expectations does not depend on dbt-utils, so there is no version conflict.
Representative uses: `unique_combination_of_columns` on composite-grain staging
models; `expect_column_values_to_be_between` on unit_price_discount (0–1).

### Incremental model — fct_stock_movements

The stock-movement ledger is append-only and dated, so the fact is
`materialized='incremental'` with `incremental_strategy='delete+insert'` and
`unique_key='transaction_id'`. On incremental runs an `is_incremental()`
watermark keeps only movements on/after the latest `transaction_date` already
in the table; delete+insert reprocesses the boundary day without duplicating
it, so re-runs are idempotent (verified: full-refresh baseline, then an
incremental no-op left row counts identical).

**Archive union.** AdventureWorks keeps only a rolling ~1-year window in
`production.transactionhistory`; older movements live in
`production.transactionhistoryarchive` (89,253 rows, 2011-04 → 2013-07,
identical schema, non-overlapping IDs — all three facts verified in-database
before the change). The fact UNION ALLs both staging models, extending
movement history to 2011–2014 so the warehouse dashboard's trend matches the
sales and purchasing dashboards. One operational subtlety: archive rows are
OLDER than the incremental watermark, so adding them required a one-off
`dbt build --full-refresh`; a normal incremental run would have silently
skipped them. The `unique` test on the surrogate key re-proves the
no-ID-overlap claim on every build.

### Snapshot — snap_product_list_price

`snapshots/snap_product_list_price.yml` uses the YAML snapshot form (current
since dbt 1.9), `strategy='timestamp'` on `modifieddate`, and a composite
unique key (product_id + price-validity start date). It captures SCD2 history
over the dated list-price changes (395 rows, all current on the static
dataset).

## 5. Test inventory

133 data tests across the project: source-layer chain tests (incl. the archive
table), staging PK and composite-grain tests, marts surrogate-key
`not_null`/`unique` and fact→dim `relationships` tests, the two custom generic
tests across 10 column applications, and the package tests. `dbt build` runs
models, snapshot and tests together; everything must be green before a phase
closes.

## 6. Handoff to Tableau Public

Tableau Desktop Public Edition has **no database connector** and Tableau
Public publishes **extracts only** — connecting Tableau directly to the
Postgres marts is impossible on the free stack. The handoff is therefore
file-based:

- `sql/export/01_export_marts_to_csv.sql` exports each of the 8 marts to
  `tableau/data/*.csv` via psql `\copy` (client-side write, overwrites on
  every run — idempotent). Run from the project root:
  `psql -d adventureworks -f sql/export/01_export_marts_to_csv.sql`
- Tableau's logical data model relates the CSVs on the existing dbt surrogate
  keys (Many-to-One, referential integrity asserted by the dbt tests), so the
  star survives the file hop without re-keying.
- One workbook (`tableau/adventureworks_operations.twbx`), three dashboards as
  tabs, published once; Tableau Public extracts to .hyper at publish time.
  Live link is in the README.

## 7. Reproducing the build

From a clone, with local PostgreSQL running and `PGPASSWORD` set (see
`.env.example`):

```
python -m venv .venv
```

```
.venv\Scripts\Activate.ps1
```

```
pip install -r requirements.txt
```

```
psql -U postgres -f install.sql        # from the adventureworks dataset folder
```

```
cd adventureworks_ops; dbt deps; dbt build
```

The dbt stack is pinned (dbt-core 1.11.8 / dbt-postgres 1.10.0) because an
unpinned install can resolve the dbt-core 2.0-alpha/Fusion build, which does
not support the Postgres adapter on Windows.

---

*Authored at Phase 5 (2026-06-10). Design decisions, risks and
diagnosis→fix→lesson loops behind this doc are tracked in the project's
session log (PROJECT_CONTEXT.md) and phase plan (PROJECT_PLAN.md).*
