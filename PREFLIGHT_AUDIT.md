# Data pre-flight audit — Mini #1 (warehouse & distribution)

> Mandatory pre-flight gate per LEARNING_ROADMAP (2026-06-05 lock). Run 2026-06-06.
> Goal: pre-screen clean, tidy, multi-table, public + redistributable warehouse/
> distribution datasets and present for Phil's GO/NO-GO. No modelling until GO.

## Method + honest limitation

Sandbox network is locked to PyPI only; raw GitHub and CDN mirrors are proxy-blocked,
so full multi-hundred-thousand-row loads could not be pulled here. A real partial pull
of Northwind confirmed schema + column types + value format; both candidates' schemas,
row profiles, and licences were confirmed from authoritative documentation. Full
row-level null/quality audit runs on Phil's local Postgres at Phase 1 load (the real
load happens there regardless). Both finalists are canonical clean teaching datasets,
so messiness risk is very low.

## Candidate A — Northwind (Postgres port: pthom/northwind_psql)

- **Story:** "Northwind Traders," a specialty-foods importer-distributor — buys from
  suppliers, warehouses, sells on to customer businesses. Textbook intermediary.
- **Shape:** 14 tables, ~3,300 rows total (order_details ~2,155, orders 830,
  customers 91, products 77, suppliers 29, employees 9, categories 8, + shippers,
  territories, region, us_states).
- **Cleanliness (verified on partial pull):** tidy types — smallint / varchar / date /
  real; NOT NULL on keys; low nulls; no unpivot, no nested JSON, no encoding mess.
- **Relational:** classic star-ish — orders → order_details → products →
  suppliers / categories; orders → customers / employees / shippers.
- **Licence:** Microsoft sample, freely redistributable; repo public.
- **dbt fit:** cleanest + fastest to stand up. BUT thin warehouse-ops surface —
  inventory is columns on products (units_in_stock / units_on_order / reorder_level),
  NO inbound purchase-order table, NO stock-movement ledger, single implicit warehouse.
  Incremental + snapshot would feel slightly contrived.
- **Verdict:** PASS on cleanliness / shape / licence; PARTIAL fit on the rich
  warehouse-operations domain Phil described.

## Candidate B — AdventureWorks distribution slice (lorint/AdventureWorks-for-Postgres)

- **Story:** bicycle-parts wholesaler. Full inbound → warehouse → outbound flow. We
  model a tidy ~10-table SLICE and ignore the manufacturing / HR / person tables.
- **Distribution slice + row profile:**
  - INBOUND: purchasing.vendor (~104), purchaseorderheader (~4,012),
    purchaseorderdetail (~8,845).
  - WAREHOUSE: production.product (~504), productinventory (~1,069 qty by location),
    location (~14 = warehouses/bins), transactionhistory (~113,443 = stock-movement
    ledger: Purchase / Sales / Transfer).
  - OUTBOUND: sales.customer (~19,820), salesorderheader (~31,465),
    salesorderdetail (~121,317).
- **Cleanliness:** canonical, well-typed, few nulls; no unpivot / nested JSON.
- **Relational:** real PO → inventory → movement → sales chain; rich but we scope a
  clean slice (dbt sources ignore the rest — not a hairball).
- **Licence:** Microsoft sample, MIT in the lorint port; public.
- **dbt fit:** BEST surface for the lead theme — natural incremental on
  transactionhistory (append-only by date), natural snapshot on product
  (listprice / standardcost as an SCD), meaningful referential + custom generic tests
  across the chain. Largest table ~121k rows = still small.
- **Cost:** one-time full DB load + slice selection; modestly more setup than Northwind.
- **Verdict:** PASS; richest fit to Phil's described domain AND to dbt depth
  (incremental + snapshot + real tests); modest extra scoping.

## Considered & rejected

- UCI/Kaggle "Wholesale customers" — 440 rows, single flat table, no relational
  structure → fails multi-table + dbt-depth. NO.
- Kaggle supply-chain / e-commerce sets (DataCo, Olist, bytadit) — auth-gated download,
  single wide flat files or retail-marketplace (overlaps Project #2). NO.
- Synthetic generation — clean fallback, but breaks the "public dataset" principle;
  hold as backup only if a finalist is vetoed.

## Wider search round 2 (2026-06-06, after Phil asked for a broader, non-training scan)

Searched Maven Analytics, data.world, data.gov.au, TPC-H, relational sample-DB repos,
Olist, Kaggle logistics. Verified new leads against their real pages.

- **Maven "US Candy Distributor"** (page verified): real distributor, CSV, multiple
  tables, **Public Domain** licence, clean — but only **499 records / 25 fields**
  (one shipment fact + lookups), geospatial-focused. Strong Tableau set, too thin for
  dbt depth (no inbound PO / inventory ledger / multi-warehouse stock; incremental +
  snapshot contrived on 499 rows). Download: public S3 zip.
- **TPC-H** (verified): clean wholesale supplier/part/partsupp/customer/orders/lineitem;
  generatable tiny; lineitem.shipdate gives a natural incremental. BUT reads as a
  synthetic benchmark to interviewers; no receiving/movement narrative; no SCD source
  for a snapshot. Decent technical surface, weak ops-story authenticity.
- **Rejected:** Olist / Maven Toys / Toy Store E-Commerce (retail — overlaps Project #2);
  Kaggle "Logistics Warehouse" (ziya07) — JS-only page, auth-gated, looks single-flat.

**Key discriminator:** the lead theme needs BOTH a natural incremental fact AND a
natural snapshot/SCD source. AdventureWorks is the ONLY candidate that supplies both
(transactionhistory + productlistpricehistory) on top of the full inbound→outbound flow.

## Recommendation (final, evidence-backed)

**Candidate B — AdventureWorks distribution slice — GO.** Verified-real schema; uniquely
satisfies the incremental + snapshot + testing/macros surface; matches every entity Phil
named. Runner-up if priorities shift toward a cleaner/lighter Tableau-geospatial story:
Maven US Candy Distributor (at the cost of a thin dbt-depth surface). Northwind/TPC-H are
clean but technically thinner for this mini. Easier AdventureWorks load: morenoh149/
postgresDBSamples (CSVs bundled in-repo).

**GO CONFIRMED 2026-06-06 (Phil).** AdventureWorks distribution slice locked. Acquisition
verified: morenoh149/postgresDBSamples/adventureworks bundles install.sql + all 72 CSVs
(~87.5 MB, slice tables all present + real-sized); clone → run install.sql → done. No MS
download, no LFS, no transformation. Build deferred — Phil resumes at Phase 1 when ready.
