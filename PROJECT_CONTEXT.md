# PROJECT_CONTEXT.md — Mini-project #1 (living context + session log)

> The carry-between-sessions memory for this mini. Read at the start of every session
> alongside TEACHING_PREFERENCES.md. PROJECT_PLAN.md holds the phase plan; this file
> holds the running state + session-by-session closeouts.
> Created 2026-06-06.

---

## One-line summary

dbt testing + macros depth on a local Postgres warehouse/distribution dataset,
published to Tableau Public. Mini #1 of 3. Target ~4-5 days.

## Locked decisions (see PROJECT_PLAN.md for detail)

- Lead theme: dbt testing + macros (custom generic tests, dbt-utils, dbt-expectations,
  one reusable macro) + one incremental model + one snapshot if time.
- Stack: local PostgreSQL + dbt-postgres → Tableau Public.
- Domain: warehouse & distribution intermediary (importer-distributor / 3PL-flavour).
  No manufacturing. Distinct from Projects #1/#2/#3.
- **Dataset LOCKED 2026-06-06 (Phil GO): AdventureWorks distribution slice** on local
  Postgres. Source: morenoh149/postgresDBSamples/adventureworks (install.sql + bundled
  CSVs, ~87.5 MB, verified). Clone → run install.sql → model a ~10-table slice via dbt
  sources. Incremental = transactionhistory; snapshot = productlistpricehistory. Full
  rationale in PREFLIGHT_AUDIT.md + PROJECT_PLAN.md.
- Folder name LOCKED: operations-analytics-dbt-tableau-project (named on stable facts;
  survives any dataset pivot at the gate). Never renamed mid-project.
- Out of scope: dbt Cloud CI/CD (training journey wk 7), Power BI.

## Open / pending

ALL PHASES COMPLETE (Phase 5 closed 2026-06-10, Session 8). Mini #1 SHIPPED:
live Tableau Public workbook (link in README) + public GitHub repo + DBT_PIPELINE.md
walkthrough. Full dbt build = 155 PASS / 0 ERROR. Screen recording dropped from scope
(Phil call, Session 8): deliverable is for interviews, not public consumption.

- Nothing open. Next: mini-project #2 kickoff (separate folder/kickoff doc).

## Working rules (this mini)

- Phil runs all git himself in PowerShell — Claude PREPARES commands, never runs git.
- One command per code block. Paste-ables in their own code blocks; everything else
  plain text, no inline backticks. SQL keywords in CAPITALS. Concise bullets.
- One direction-check question max per response; default to most professional senior
  choice otherwise. Build mode (deep teaching deferred).
- End-of-session: one bundled commit. README carries the AI-assistance disclosure block.

## Session log

### Session 1 — 2026-06-06 — Phase 0 kickoff (re-anchor + plan + pre-flight) — CLOSED
- Re-anchored from MINI1_KICKOFF.md + TEACHING_PREFERENCES.md + LEARNING_ROADMAP.md
  (2026-06-06 entry) + LEARNINGS.md carry-forward.
- Authored fresh PROJECT_PLAN.md + this PROJECT_CONTEXT.md + README.md + PREFLIGHT_AUDIT.md.
- Ran data pre-flight in two rounds. Round 1: Northwind + AdventureWorks + rejected
  Kaggle/UCI sets. Round 2 (Phil asked for a wider, non-training scan): added Maven US
  Candy Distributor, TPC-H, Olist, Maven Toys, Kaggle logistics — verified against real
  pages. Discriminator: this mini needs BOTH a natural incremental fact AND a snapshot
  source; AdventureWorks is the only candidate giving both.
- Verified AdventureWorks acquisition is real + clean: morenoh149 repo bundles install.sql
  + all slice CSVs (~87.5 MB), no MS download / no LFS / no transformation.
- **Dataset LOCKED by Phil: AdventureWorks distribution slice. GO.**
- Decision: lock + document only this session; build deferred. Phil resumes at Phase 1
  when ready.
- Next session starts at: Phase 1 (load Postgres + dbt sources). See PROJECT_PLAN.md.

### Session 2 — 2026-06-08 — Phase 1 build (environment + load + sources) — CLOSED
- Read ENGINEERING_STANDARDS.md (Phil added it to the repo mid-session) and wired its
  three audit layers into the workflow: phase-kickoff forward-verify pass, per-script
  10-criteria audit, phase-boundary structural audit.
- Ran the Phase 1 kickoff forward-verify pass. Banked risks: R1 (high) unpinned
  pip install can resolve dbt-core 2.0-alpha/Fusion which breaks the postgres adapter
  on Windows → mitigated by pinning dbt-core 1.11.8 + dbt-postgres 1.10.0 in
  requirements.txt; R2 install.sql uses relative data/ paths (run psql from the
  adventureworks folder); R3 full 68-table load expected (we slice via sources);
  R4 morenoh149 ships pre-processed CSVs (no Ruby step); R5 standardised on a
  lowercase unquoted DB name (adventureworks).
- Environment: confirmed Postgres 18.3 running; added the Postgres bin to PATH;
  created a project .venv with the pinned dbt stack (dbt-core 1.11.8 / dbt-postgres
  1.10.0); dbt debug all-green.
- Data: cloned morenoh149/postgresDBSamples to a sibling folder (keeps the 87 MB dump
  out of the portfolio repo); drop-and-recreate loaded the adventureworks DB via
  install.sql (68 tables); verified the 12-table distribution slice against expected
  row counts — exact parity (sql/verify/01_phase1_source_load_verification.sql).
- dbt: scaffolded adventureworks_ops/ (--skip-profile-setup); authored profiles.yml
  with the password via env_var (no secret in repo); removed the example models;
  defined 12 sources in models/staging/_adventureworks__sources.yml with not_null/
  unique/relationships tests. dbt test --select "source:*" → 43 PASS / 0 fail.
- Source freshness intentionally omitted (static 2014 data → always stale); left a
  commented illustrative example on transactionhistory.
- Phase-boundary structural audit: 1 finding fixed in-session (.user.yml gitignored).
  10-criteria audit on Phase 1 artifacts: all PASS.
- Files added: requirements.txt, .gitignore, .env.example, sql/verify/01_*.sql,
  adventureworks_ops/ (dbt project) incl. profiles.yml + sources. README updated
  (Phase 1 status + reproducible setup); AI-disclosure block already present.
- GitHub repo created + inaugural bundled commit pushed at session close (first push).
- Next session starts at: Phase 2 (staging + core models). Run the Phase 2 forward-verify
  pass first.

### Session 3 — 2026-06-08 — Phase 2 build (staging + core star) — CLOSED
- Ran the Phase 2 forward-verify pass (docs.getdbt.com): banked Risks M1-6/7/8 in
  LEARNINGS before building. Decisions: single output schema (no per-folder +schema,
  avoids target.schema_custom concatenation); dbt-utils pulled forward from Phase 3 and
  pinned 1.3.3 in packages.yml; generate_surrogate_key for fact/dim keys.
- Built 12 staging models (one per source, import/final CTE, snake_case rename, light
  DATE recasts, rowguid dropped) materialized as views; _staging__models.yml with PK
  not_null/unique. Columns verified against information_schema first (not assumed).
- Built 8 marts as tables: dim_product/dim_vendor/dim_customer/dim_location +
  fct_purchase_order_lines/fct_sales_order_lines/fct_stock_movements/fct_product_inventory
  (added the inventory fact so dim_location isn't an orphan). Surrogate keys via
  dbt_utils.generate_surrogate_key; star integrity via relationships tests fact->dim.
- Migrated all relationships tests (sources + marts) to the dbt 1.11 arguments: syntax;
  full dbt build now 132 PASS / 0 ERROR / 0 deprecations.
- Verification: row-count parity fct vs source exact on all three line/movement facts
  (sales 121317, PO 8845, stock 113443). 10-criteria audit all PASS; structural audit
  clean (20 models, 3 schema YAMLs, all paired, no stray .gitkeep).
- Credential handling fixed permanently: pgpass.conf failed on Windows (libpq resolves
  localhost->::1 and skips the file). Switched to PGPASSWORD env var set once via setx;
  profiles.yml reads env_var('PGPASSWORD'); psql + dbt both authenticate, every terminal,
  no per-session password, nothing secret in the repo. (Old DBT_PG_PASSWORD retired.)
- TODO carry-forward: rotate the Postgres password (it was shown on screen during setup).
- Next session starts at: Phase 3 (dbt depth — custom generic tests, dbt-utils +
  dbt-expectations, reusable macro, incremental + snapshot).

### Session 4 — 2026-06-08 — Phase 3 build (dbt depth — the lead theme) — CLOSED
- Ran the Phase 3 forward-verify pass (engine-docs-first: docs.getdbt.com +
  hub.getdbt.com). Banked Risks M1-9..13 in LEARNINGS; baked decisions into
  PROJECT_PLAN Phase 3. Key result: feared dbt-utils conflict RETIRED —
  dbt-expectations 0.10.10 depends only on godatadriven/dbt_date, not dbt-utils.
- Packages: pinned metaplane/dbt_expectations 0.10.10 + godatadriven/dbt_date
  (resolved 0.18.0) in packages.yml; dbt_utils 1.3.3 retained. dbt deps clean,
  no conflict. NOTE canonical dbt-expectations namespace is metaplane, not calogica.
- Reusable macro: extended_amount() centralises the qty*price (+ optional discount)
  line rule; wired into fct_sales_order_lines (gross + net) and
  fct_purchase_order_lines (line_amount), removing 3 hand-written copies. Compiled
  SQL identical — fact values unchanged (verified by targeted build).
- Custom generic tests authored from scratch in tests/generic/: not_negative
  (applied to 9 qty/money columns across the two line facts) and at_or_below_column
  (net_amount <= gross_amount on sales). Args via the dbt 1.11 arguments: nesting.
- Package tests applied: dbt_utils.unique_combination_of_columns on the 3
  composite-grain staging models (product_vendor, product_inventory,
  price_history); dbt_expectations.expect_column_values_to_be_between on
  unit_price_discount (0-1).
- Incremental model: converted fct_stock_movements to materialized=incremental,
  incremental_strategy=delete+insert, unique_key=transaction_id, is_incremental()
  watermark on transaction_date. dbt-postgres supports append/merge/delete+insert/
  microbatch (PG18 native MERGE). Verified idempotent: full-refresh base then
  incremental no-op = 113,443 rows unchanged, zero duplication.
- Snapshot: snap_product_list_price.yml (YAML form, dbt 1.9+), timestamp strategy on
  modified_date, composite unique_key (product_id::text || '-' || start_date::text),
  default analytics schema (no schema concatenation). 395 rows, all current
  (dbt_valid_to NULL).
- Full dbt build = 147 PASS / 0 ERROR / 0 WARN (21 nodes incl. 1 incremental + 1
  snapshot + 12 views + 7 tables; 126 data tests). 10-criteria audit all PASS;
  structural audit: 1 finding fixed in-session (git rm 3 stale .gitkeep in
  macros/tests/snapshots).
- Auth resolved (was the carry-forward pain): PGPASSWORD wasn't loading in VS Code's
  integrated terminal because setx/SetEnvironmentVariable(User) writes the registry
  but does NOT reach already-running processes — VS Code was launched before the save.
  Fix: SetEnvironmentVariable('PGPASSWORD',pw,'User') + FULL VS Code restart, then
  verified both session AND permanent store = True. The missing step previously was
  the VS Code restart. Now automatic for every future terminal this project.
- Password rotation TODO: Phil declined — dropped from scope.
- Next session starts at: Phase 4 (Tableau Public). Confirm Tableau Public account
  first.

### Session 5 — 2026-06-08 — Phase 4 start (Dashboard 1 — Outbound: Sales & Customer) — CLOSED
- Ran the Phase 4 kickoff forward-verify pass (help.tableau.com). Banked Risks
  M1-14..18 in LEARNINGS; mitigations baked into PROJECT_PLAN Phase 4. KEY finding
  (M1-14, confirmed live in the app): Tableau Desktop PUBLIC EDITION has NO database
  connector (file/Google Drive/OData/WDC only) and Public publishes EXTRACTS only.
  So "connect to the marts" is impossible — the path is dbt marts -> CSV -> Public.
- Tableau Public account: confirmed (Phil's pre-existing account still active, signed
  in). Installed Tableau Public Desktop Edition 2026.1.
- Data handoff: authored sql/export/01_export_marts_to_csv.sql (psql \copy, idempotent
  drop-and-recreate, run from project root with -U postgres). Exported all 8 marts to
  tableau/data/*.csv; verified row-count parity CSV-vs-COPY on every file (sales
  121317, stock 113443, PO 8845, inventory 1069, dims 504/104/19820/14). ~38 MB total,
  largest 22 MB (under GitHub 100 MB).
- Dashboard structure LOCKED (Phil GO): ONE workbook, THREE dashboards as tabs,
  published once = one live link. Sessions 5/6/7 = Dashboard 1/2/3. Rationale: this is
  the ONLY Tableau deliverable across all minis+majors, so concentrate the proof here.
- Built the sales data source: fct_sales_order_lines related to dim_product (Product
  Key) + dim_customer (Customer Key); cardinality Many->One + referential integrity
  All->Some set explicitly (verified by the dbt unique/relationships tests).
- Dashboard 1 (Outbound: Sales & Customer): 5 KPI tiles (Net Sales 109.8M, Units Sold
  274,914, Orders 31,465, Avg Order Value 3,491, Customers 19,119) + Throughput
  (monthly net revenue) + Top Products + Sales by Product Line + Sales by Customer Type.
  Calc field Product Line (label) handles padded category codes (TRIM) + maps R/M/T/S
  -> Road/Mountain/Touring/Standard + NULL -> "Components / Other". Year filter applied
  to all worksheets on the source.
- Styling pass (Claude drove via computer-use, Phil finished): teal throughput line
  (thicker), categorical Product Line, themed bars, KPI numbers 20pt with orange labels,
  container-based layout (Horizontal KPI row + Throughput band + Horizontal chart row).
- Saved canonical tableau/adventureworks_operations.twbx + _SAFETY copy (gitignored via
  tableau/*_SAFETY.twbx). .gitignore also ignores *.twbr recovery files.
- Trailing partial month (June 2014, 2,130 lines vs May 8,626) trimmed from the trend
  via a worksheet-only Order Date exclude (KPI totals unchanged at 109.8M). Trend
  worksheet renamed Throughput -> Monthly Net Sales (it plots net_amount, not volume).
  Redundant chart headers removed + axes tidied (Phil).
- Files this session: sql/export/01_export_marts_to_csv.sql, tableau/data/*.csv (8),
  tableau/adventureworks_operations.twbx, .gitignore, PROJECT_PLAN.md (Phase 4 block),
  LEARNINGS.md (M1-14..18, local/gitignored), this log.
- Next session starts at: Session 6 = Dashboard 2 (Inbound: Supplier & Purchasing) —
  new data source fct_purchase_order_lines + dim_product + dim_vendor.

### Session 6 — 2026-06-09 — Phase 4 cont. (Dashboard 2 — Inbound: Supplier & Purchasing) — CLOSED
- Mini forward-verify for D2: the only new technique was a Pareto (dual-axis bar +
  cumulative-% table calc) — an in-app viz pattern, NOT a Public-platform behaviour, so
  no new risk beyond M1-14..18. Confirmed, nothing banked.
- Built the Purchasing data source: fct_purchase_order_lines related to dim_product
  (Product Key) + dim_vendor (Vendor Key); cardinality Many->One, referential integrity
  All->Some — matches the dbt unique/relationships tests. Renamed source "Purchasing".
- Dashboard 2 (Inbound - Supplier & Purchasing): 5 KPI tiles (PO Spend 63.79M, Units
  Purchased 2,348,637, Purchase Orders 4,012, Avg PO Value 15,900, Vendors 86 — Avg ties
  out: 63.79M/4,012 = 15,900) + Monthly PO Spend trend + Top Vendors by Spend (top-10
  set via Line Amount Sum) + Purchase Volume by Product Line (units) + Spend Concentration.
- Calcs: Product Line (label) mirrored from D1 (TRIM + R/M/T/S -> Road/Mountain/Touring/
  Standard, NULL -> "Other" per Phil); Avg PO Value; Total PO Spend / Units Purchased /
  Purchase Orders / Vendors; Vendor Group (IF [Top 10 Vendor Set] THEN "Top 10 vendors"
  ELSE "Other vendors").
- Trend trim: excluded trailing partial months Aug + Sep 2014. Verified against the CSV —
  Aug 2014 = 104 lines across only 3 dates (Aug 1-3), Sep = 2 lines (Sep 22); last FULL
  month = July 2014 (904 lines, $6.82M). KPI totals stay on the full dataset (cosmetic
  trim only), same approach as D1 (whose sales partial was June 2014). Each fact trimmed
  to its OWN last full month — consistency is the method, not a shared calendar cut.
- Pareto built + styled (Classic 10 green/orange) but did NOT fit a 1/3 tile (dual $/%
  axes need width). Attempted a 2x2 rearrange via computer-use; Tableau's vertical
  container resists splitting a full-width tile left/right (every edge resolves to a new
  row), so the 2x2 fought us. Phil call: REPLACE the Pareto with a 2-slice pie "Spend
  Concentration" (Top 10 vendors 43% vs Other 76 vendors 57%) — clean at tile size, keeps
  the concentration insight, and avoids echoing the product-line bars. No dominant vendor
  (max 7.1%), so a vendor treemap was rejected as a uniform patchwork.
- Year of PO Date filter applied to ALL worksheets on the Purchasing source; verified all
  four vizzes update together (2013 test: PO Spend 20.06M, pie 42.72/57.28 ties to the KPI).
- D3 layout LOCKED in PROJECT_PLAN (Phil GO): differentiated from the D1/D2 twins — left
  KPI rail, inventory map hero, reorder-point alert panel, Location filter (not Year).
- Styling: standardised on Tableau Classic 10 (Phil's choice) across categorical marks;
  teal trend line; orange KPI labels; container layout mirroring D1.
- Structural audit: tableau/ clean — only canonical .twbx tracked; _SAFETY.*, *.twb,
  *.twbr gitignored (verified via git check-ignore). Could not byte-introspect the .twbx
  from the sandbox (stale mount snapshot); verification rests on in-app screenshots + save.
- Files this session: tableau/adventureworks_operations.twbx (D2 added), PROJECT_PLAN.md
  (D3 layout lock), PROJECT_CONTEXT.md (this log).
- Next session starts at: Session 7 = Dashboard 3 (Warehouse: Inventory & Stock Movement)
  + publish all three tabs + embed live link in README + Phase 4 structural audit +
  final bundled commit.

### Session 7 — 2026-06-09 — Phase 4 cont. (Dashboard 3 — Warehouse: Inventory & Stock Movement) — CLOSED
- Built the two D3 data sources: Inventory (fct_product_inventory + dim_product +
  dim_location; relate on Product Key + Location Key, Many->One, All->Some) and Stock
  Movements (fct_stock_movements + dim_product on Product Key, Many->One, All->Some).
  Two sources by design, not one: the two facts are at different grains and both join
  dim_product, so one source would fan-out/inflate. Side effect documented: the Location
  filter cannot touch the movements trend (fct_stock_movements has no location column).
  Also renamed the D1 source fct_sales_order_lines -> "Sales" for naming consistency
  (Sales / Purchasing / Inventory / Stock Movements).
- LOCKED-LAYOUT CHANGE (forced by the data, Phil GO): the "map hero" in the locked D3
  layout is impossible — dim_location's 14 rows are internal warehouse/manufacturing
  zones (Tool Crib, Subassembly, Final Assembly, Paint Shop, Finished Goods Storage...),
  not geographic places; no lat/long, won't geocode. Replaced the map with an
  Inventory-by-Zone TREEMAP (tile size + colour = on-hand qty). Treemap chosen over
  ranked bars / heatmap as the most differentiated hero. On-hand is genuinely lopsided
  (Subassembly 95,477; Misc Storage 83,173; Tool Crib 72,899 ... Paint Storage 110).
- 9 calcs authored (8 on Inventory, 1 on Stock Movements). Inventory: Product Line
  (label) [reused R/M/T/S->Road/Mountain/Touring/Standard + NULL->Components/Other, TRIM
  for padded codes], On Hand Qty (later renamed labels), SKUs On Hand (COUNTD product),
  Active Zones (COUNTD location), On Hand per Product + Reorder Point per Product (FIXED
  [Product Key] LODs), Below Reorder? + Items Below Reorder, and Reorder Status (Below /
  Near = within 20% above / OK). Stock Movements: Movement Type (P/S/W -> Purchase / Sale
  / Work order) — but the raw "Stock Movement Type" field already carried those labels
  from the dbt model, so that field was used directly. Numeric measures defaulted to 0dp
  thousands-separator number format.
- 5 worksheets + 4 KPI tiles. Reorder Alerts panel: horizontal bars of On Hand per
  Product for at-risk items, grouped by Reorder Status (red Below / amber Near), with a
  CELL-SCOPED reference line (Reorder Point per Product, MIN) drawing each item's reorder
  threshold per bar — shows proximity to reorder at a glance.
- Final D3 layout = differentiated from the D1/D2 twins: LEFT full-height KPI rail
  (Stock On Hand 335,974 / SKUs 432 / Active Zones 14 / Below Reorder 8) + 2x2 grid
  (Movements top-left, Stock by Product Line top-right, Reorder Alerts bottom-left,
  Inventory treemap bottom-right) + Location Name filter. Title "Warehouse: Inventory &
  Stock Movement" / subtitle "On-hand, reorder & stock movement · 2013-2014".
- DASHBOARD-ASSEMBLY PAIN (banked in LEARNINGS): Tableau Desktop CANNOT drag-reorder
  tiled items in the Layout item hierarchy (that is Cloud/Server only). Dropping sheets
  onto the bare canvas or pre-building empty nested containers spawns stray auto-"Tiled"
  wrapper containers and mis-nests. What worked (Claude drove via computer-use after
  repeated instruction failures): set size first, then build RAIL-FIRST (stack the 4 KPIs
  into a full-height vertical), drop Movements to its right (split), then split the right
  cell into the 2x2. Two drop rules: tile cleanly by releasing hard against the target's
  boundary (with a dwell); split an INNER cell (not the outer container) by releasing in
  that cell's directional zone AWAY from the outer edge. Right-edge drops float unless
  released within ~3px of the boundary.
- Trend trim: excluded BOTH partial ends of Stock Movements via a worksheet Transaction
  Date range filter 1 Aug 2013 - 31 Jul 2014 (July 2013 = 1 day / the 31st; Aug 2014 =
  3 days) -> clean 12 full months Aug 2013 - Jul 2014. KPI totals unaffected (Inventory
  source). Verified monthly row/day counts from the CSV.
- DATA CHARACTERISTIC surfaced by Phil + DECISION: D3's movement history is only ~Aug
  2013 - Jul 2014 because fct_stock_movements derives from AdventureWorks
  Production.TransactionHistory — a rolling ~1-year live ledger; older movements live in
  Production.TransactionHistoryArchive, which was EXCLUDED from the Phase-0/1 slice as
  out-of-scope for the dbt-technique goal (it added rows, not technique, under the
  "tiny/clean slice" guardrail). Sales (2011-05->2014-06) and PO (2011-04->2014-09) keep
  full history, hence the mismatch. The miss was not flagging this trade-off when D3 was
  designed. DECISION (Phil GO, deferred to next session): UNION
  TransactionHistoryArchive into the stock-movements model (identical schema, transaction
  IDs don't overlap, incremental logic holds) -> rebuild + re-test + re-export CSV +
  refresh extract -> D3 trend extends to ~2011-2014, consistent with D1/D2. Only
  fct_stock_movements is affected; Sales / PO / inventory-snapshot are untouched (different
  source tables; inventory is point-in-time, no time axis).
- TEACHING_PREFERENCES updated this session: FOURTH re-lock (2026-06-09) — three standing
  rules consolidated after drift in this build session: (1) name the table AND data source
  for every field/step, always; (2) zero inline code in chat, plain text only; (3) bullets
  by default with indented sub-bullets for hierarchy.
- Files this session: tableau/adventureworks_operations.twbx (D3 added; canonical only —
  SAFETY copy gitignored), TEACHING_PREFERENCES.md (FOURTH re-lock), PROJECT_PLAN.md (D3
  map->treemap + archive next-session task), PROJECT_CONTEXT.md (this log), LEARNINGS.md
  (Tableau-assembly + archive-gap entries, local/gitignored).
- NOT done (carried to next session): union TransactionHistoryArchive; FULL formatting
  pass across D1 + D2 + D3 (consistency + polish, incl. "Final Assembly" treemap label);
  publish all 3 tabs to Tableau Public + live link; README live link + ad-blocker caveat +
  movement-history note; Phase 4 structural audit; Phase 5 ship (DBT_PIPELINE.md +
  recording).
- Next session starts at: Session 8 = TransactionHistoryArchive union (rebuild/re-test/
  re-export/refresh) -> full D1/D2/D3 formatting pass -> publish -> README -> Phase 4
  structural audit -> Phase 5 ship + final bundled commit.

### Session 8 — 2026-06-10 — Phase 4 finish + Phase 5 ship (archive union, publish, docs) — CLOSED
- ARCHIVE UNION done. Pre-flight verified in-database first (Eng Standards #9): schemas
  identical (0 mismatched columns), transaction IDs non-overlapping (0), archive =
  89,253 rows 2011-04-16 -> 2013-07-30. Added transactionhistoryarchive source (+tests),
  stg_production__transaction_history_archive (1:1 mirror), UNION ALL in
  fct_stock_movements with the is_incremental() watermark on the unioned set. One-off
  dbt build --full-refresh REQUIRED (archive rows predate the watermark; a normal
  incremental run would silently skip them). Full build = 155 PASS / 0 ERROR (was 147;
  +1 model +7 tests). Fact verified: 202,696 rows (113,443 + 89,253), 2011-04-16 ->
  2014-08-03. Stock-movements CSV re-exported (single targeted \copy); Tableau extract
  refreshed; D3 trend filter widened to 1 May 2011 - 31 Jul 2014 (first/last FULL
  months); D3 subtitle now 2011-2014.
- Auth detour: psql failed as user "Phil" — NOT the old PGPASSWORD issue; -U postgres
  was missing from prepared commands (libpq defaults user to the OS login). Permanent
  fix: PGUSER=postgres set User-scope alongside PGPASSWORD (LEARNINGS M1-24).
- FORMATTING PASS done across D1/D2/D3. D3: trend renamed Monthly Stock Movements
  (matches D1/D2 naming), product-line colours matched to the D1/D2 mapping (Mountain
  blue / Road green / Touring purple / Standard red / Other orange), Reorder Alerts
  axis unclipped; treemap "Final Assembly" truncation ACCEPTED (tooltip carries it).
  D1: Top Products axis fixed to include zero (was misleadingly truncated at $2.0M);
  "Components / Other" renamed "Other" everywhere (Phil call — shorter). Phil's own
  gradient-trend + multi-colour-bar styling on D1/D2 confirmed as the matched-twin
  standard (Claude's stale-notes objection withdrawn). Label/tooltip split via
  duplicate measure (compact $M labels, full-dollar tooltips) on Top Products + Sales
  by Product Line (M1-23, KB-verified technique).
- PUBLISHED to Tableau Public. Gotchas banked (M1-22): publish dialog offered no
  rename (name = filename); Edit Details no longer holds the tabs toggle — Show Sheets
  as Tabs is behind the GEAR icon on the viz page; first tabs attempt exposed EVERY
  worksheet -> fixed in Desktop via right-click dashboard tab -> Hide All Sheets (x3)
  -> re-save to Public (overwrites in place, metadata persists). Renamed to
  "AdventureWorks Operations", description added (<231 chars). Filter-scope bug found
  by Phil ON THE LIVE PAGE: D1 Year filter only drove the trend -> Apply to Worksheets
  -> All Using This Data Source on D1/D3, D2 verified, republished, retested green
  (M1-25). Viewer download left ON.
- README: live link (Original-view share URL) + 3 dashboard screenshots embedded
  (tableau/screenshots/01-03_*.png) + ad-blocker caveat + movement-history one-liner;
  status block -> Phase 4 complete / 155 PASS. Stale DBT_PG_PASSWORD references purged
  from README + .env.example (now PGPASSWORD per the locked auth pattern).
- Phase 4 STRUCTURAL AUDIT: all PASS (canonical .twbx only; SAFETY/.twb/.twbr +
  personal files gitignored — verified via git status; 8 CSVs; model/YAML pairings;
  docs current).
- Phase 5: DBT_PIPELINE.md authored (layer-by-layer walkthrough: sources -> staging ->
  star -> macro / custom generic tests / packages / incremental + archive union /
  snapshot -> CSV handoff -> Tableau constraints -> reproduce-from-scratch). README
  cross-linked. SCREEN RECORDING DROPPED (Phil call: interview-facing, employers won't
  watch it; not public-facing content). LEARNINGS M1-22..25 banked (local/gitignored).
- Files this session: adventureworks_ops models (archive source/staging/union + YAMLs),
  tableau/adventureworks_operations.twbx, tableau/data/fct_stock_movements.csv,
  tableau/screenshots/ (3 new), README.md, .env.example, DBT_PIPELINE.md (new),
  PROJECT_CONTEXT.md (this log). One bundled commit + push at close.
- MINI #1 COMPLETE. Next: mini-project #2 kickoff.
