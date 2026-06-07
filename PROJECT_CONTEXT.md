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

## Open / pending (Phase 3 — dbt depth: the lead theme, NOT started)

- Custom generic test(s) authored from scratch.
- dbt-utils (already installed, pinned 1.3.3) + dbt-expectations tests across models.
- One reusable macro.
- One incremental model (transactionhistory). One snapshot (productlistpricehistory)
  if time.
- Tableau Public account: still to confirm before Phase 4 (not needed yet).

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
