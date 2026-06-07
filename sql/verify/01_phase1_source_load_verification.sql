-- Phase 1 source-load verification
-- Confirms the wholesale-distribution slice loaded into the adventureworks DB.
-- Reports ACTUAL row counts; approximate expected counts (from PREFLIGHT_AUDIT.md)
-- are reference comments only -- eyeball for parity, do not treat as hard pass/fail
-- (see ENGINEERING_STANDARDS.md criterion 9, the magic-number caveat).
--
-- Slice + approx expected rows:
--   INBOUND   purchasing.vendor               ~104
--             purchasing.productvendor        ~460
--             purchasing.purchaseorderheader  ~4,012
--             purchasing.purchaseorderdetail  ~8,845
--   WAREHOUSE production.product              ~504
--             production.productinventory     ~1,069
--             production.location             ~14
--             production.transactionhistory   ~113,443   (incremental-model source)
--             production.productlistpricehistory ~395     (snapshot source)
--   OUTBOUND  sales.customer                  ~19,820
--             sales.salesorderheader          ~31,465
--             sales.salesorderdetail          ~121,317

SELECT 'purchasing.vendor'                AS table_name, COUNT(*) AS row_count FROM purchasing.vendor
UNION ALL
SELECT 'purchasing.productvendor',        COUNT(*) FROM purchasing.productvendor
UNION ALL
SELECT 'purchasing.purchaseorderheader',  COUNT(*) FROM purchasing.purchaseorderheader
UNION ALL
SELECT 'purchasing.purchaseorderdetail',  COUNT(*) FROM purchasing.purchaseorderdetail
UNION ALL
SELECT 'production.product',              COUNT(*) FROM production.product
UNION ALL
SELECT 'production.productinventory',     COUNT(*) FROM production.productinventory
UNION ALL
SELECT 'production.location',             COUNT(*) FROM production.location
UNION ALL
SELECT 'production.transactionhistory',   COUNT(*) FROM production.transactionhistory
UNION ALL
SELECT 'production.productlistpricehistory', COUNT(*) FROM production.productlistpricehistory
UNION ALL
SELECT 'sales.customer',                  COUNT(*) FROM sales.customer
UNION ALL
SELECT 'sales.salesorderheader',          COUNT(*) FROM sales.salesorderheader
UNION ALL
SELECT 'sales.salesorderdetail',          COUNT(*) FROM sales.salesorderdetail
ORDER BY table_name;
