# PROJECT_PLAN.md — Mini-project #1

> Operations Analytics: dbt depth → Tableau Public, on a warehouse & distribution dataset.
> Authored 2026-06-06 at Phase 0. Living plan — phases tick off as they ship.
> Read alongside PROJECT_CONTEXT.md (session log), TEACHING_PREFERENCES.md (how I work),
> LEARNING_ROADMAP.md (where this mini sits), LEARNINGS.md (carry-forward).

---

## What this is

First of three "calibrated stretch" mini-projects bridging BI Analyst → Senior BA /
BI Developer (Melbourne, AU). The bar is a **believable one-step skill growth, fully
owned and explainable line-by-line** — NOT "impressive." One tight new named skill:
**dbt testing + macros depth**, plus an **independent Tableau Public** proof.

## Locked scope

- **Lead theme (ONE, so it doesn't sprawl): dbt testing + macros.**
  - Custom **generic tests** (schema tests authored from scratch).
  - **dbt-utils** + **dbt-expectations** packages in use.
  - One **reusable macro**.
- **Plus:** one **incremental model**; one **snapshot** IF time allows.
- **Warehouse:** local **PostgreSQL** + **dbt-postgres** (known from Project #1).
- **Output:** **Tableau Public** workbook (free, shareable live link). Tableau Desktop
  is a 14-day trial only — Public is the portfolio artefact.
- **NOT in scope:** dbt Cloud CI/CD (moved to the training journey, week 7); Power BI
  (this mini is the Tableau proof); manufacturing (we are a distribution intermediary,
  not a manufacturer).

## Domain

**Warehouse & distribution — a wholesale/distribution intermediary** (importer-
distributor, 3PL-flavour). We buy already-manufactured finished goods FROM
manufacturers/suppliers, warehouse them, and sell them ON to retailer customers.
No manufacturing. Entities in play: SKUs/products, suppliers, retailer customers,
warehouse locations, inbound purchase orders, outbound sales orders, stock movements,
inventory levels.

Must stay **distinct** from Project #2 (retail demand/forecasting), Project #1
(transit), Project #3 (corporate finance). Serves both CV tracks at once — the dbt
TECHNIQUE for the Data/BI track, the operations SUBJECT MATTER for the Operations
Analyst track.

## Guardrails

- **Time:** ~4-5 days; all three minis ~2 weeks total. If this passes 5 days, CUT
  scope — do not extend.
- **Data cleanliness is the gate.** Tiny + already-clean. NO unpivot / nested-JSON /
  overnight loads / audit campaigns. If a dataset needs that, pick a different one.
- **Mandatory data pre-flight before any modelling** (see Phase 0). Phil signs off
  GO/NO-GO on the dataset first.
- **Build mode** by default; deep teaching deferred to the training journey.

## Dataset

**STATUS: LOCKED 2026-06-06 (Phil GO).** AdventureWorks distribution slice on Postgres.

- **Source:** morenoh149/postgresDBSamples → adventureworks/ (README + install.sql +
  data/ with all 72 tab-delimited CSVs, ~87.5 MB; verified present + real-sized).
  Microsoft sample data; freely redistributable. No separate MS download, no LFS, no
  transformation step.
- **Acquisition:** clone the adventureworks/ folder → run install.sql against local
  Postgres → done. Loads the full 68-table DB; we model a ~10-table slice via dbt
  `sources` and ignore the rest.
- **Slice we model (the wholesale-distribution flow, manufacturing/HR ignored):**
  - INBOUND: purchasing.vendor, purchaseorderheader, purchaseorderdetail, productvendor.
  - WAREHOUSE: production.product, productinventory (qty by location), location,
    transactionhistory (~113k stock-movement ledger: P/S/W).
  - OUTBOUND: sales.customer, salesorderheader, salesorderdetail (~121k).
- **dbt-depth surfaces this dataset gives us:**
  - Incremental model → transactionhistory (append-only, dated).
  - Snapshot → productlistpricehistory (dated price changes = natural SCD source).
  - Tests → referential integrity across PO → inventory → movement → sales; custom
    generic tests; dbt-utils + dbt-expectations.
- Full audit + rationale: PREFLIGHT_AUDIT.md. One-paragraph data-audit note lives in
  README (gate output).

## Phase plan

**Phase 0 — Setup + data pre-flight (here).**
- Author this plan + PROJECT_CONTEXT.md. ✅
- Pre-screen + audit warehouse/distribution datasets against the 6-point gate; wider
  second-round search; present for GO/NO-GO. ✅ (AdventureWorks slice locked 2026-06-06)
- After GO: confirm local Postgres + dbt-postgres + Tableau Public account ready;
  create the public GitHub repo shell. ✅ Postgres + dbt-postgres confirmed and GitHub
  repo created at the Phase 1 session close (2026-06-08). Tableau Public account still
  to confirm before Phase 4.

**Phase 1 — Load + source. ✅ (2026-06-08)** AdventureWorks loaded into local Postgres
via a drop-and-recreate (idempotent) `install.sql` run; 12-table distribution slice
verified at exact row-count parity. dbt project scaffolded; 12 `sources` defined with
`not_null`/`unique`/`relationships` tests — `dbt test --select "source:*"` = 43 PASS.
Source freshness intentionally omitted (static historical data). Note: data loads into
its native AdventureWorks schemas (purchasing/production/sales), not a single `raw`
schema — dbt `sources` point straight at them.

**Phase 2 — Staging + core models. ✅ (2026-06-08)** 12 staging views + 8 marts
tables (dim_product, dim_vendor, dim_customer, dim_location, fct_purchase_order_lines,
fct_sales_order_lines, fct_stock_movements, fct_product_inventory). Surrogate keys via
dbt_utils.generate_surrogate_key; star integrity via relationships tests. Full
`dbt build` = 132 PASS / 0 ERROR / 0 deprecations; fact row-count parity exact.

Phase 2 forward-verify decisions (banked 2026-06-08, see LEARNINGS Risks M1-6/7/8):
- Single output schema for ALL models — no per-folder `+schema` config (avoids the
  `target.schema_custom` concatenation). Layers are distinguished by name prefix
  (`stg_`/`dim_`/`fct_`), not by schema.
- dbt-utils pulled forward from Phase 3 to Phase 2 (Phil GO): pin
  `dbt-labs/dbt_utils: 1.3.3` in `packages.yml`, run `dbt deps`, use
  `generate_surrogate_key(['…'])` for fact/dim surrogate keys rather than hand-rolling.
- Staging = `view`; warehouse/marts = `table` (dbt_project.yml per-folder defaults).

**Phase 3 — dbt depth (the lead theme).**
- Custom generic test(s) authored from scratch.
- dbt-utils + dbt-expectations tests applied across models.
- One reusable macro.
- One incremental model. One snapshot if time.

**Phase 4 — Tableau Public.** Connect Tableau to the Postgres marts (or an extract),
build the operations workbook (inventory/throughput/supplier/customer views), publish
to Tableau Public, embed the live link in README.

**Phase 5 — Ship.** README (with AI-assistance disclosure block), DBT_PIPELINE.md
walkthrough, screen recording, bundled commit + push. Bank LEARNINGS entries.

## Deliverables

- Public GitHub repo: dbt project (models, tests, macros, packages.yml), Postgres
  loader, README + walkthrough doc, screen recording.
- Live Tableau Public workbook link.
- Carry-forward LEARNINGS entries for the training journey.
