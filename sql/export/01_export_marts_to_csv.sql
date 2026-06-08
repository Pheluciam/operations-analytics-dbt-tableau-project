-- 01_export_marts_to_csv.sql
-- Export the 8 dbt marts (analytics schema) to one CSV per mart for Tableau Public.
-- Why: Tableau Desktop Public Edition has no database connector and Tableau Public
-- publishes extracts only (LEARNINGS Risks M1-14/M1-15), so the marts are handed off
-- as flat files. \copy writes client-side and overwrites on every run (idempotent,
-- Eng Standards #8). Run from the PROJECT ROOT so the relative paths resolve:
--   psql -d adventureworks -f sql/export/01_export_marts_to_csv.sql
-- Auth is PGPASSWORD (already set permanently); no password prompt expected.

\echo Exporting analytics marts to tableau/data/ ...

-- Dimensions
\copy (SELECT * FROM analytics.dim_product)             TO 'tableau/data/dim_product.csv'             WITH (FORMAT csv, HEADER true)
\copy (SELECT * FROM analytics.dim_vendor)              TO 'tableau/data/dim_vendor.csv'              WITH (FORMAT csv, HEADER true)
\copy (SELECT * FROM analytics.dim_customer)            TO 'tableau/data/dim_customer.csv'            WITH (FORMAT csv, HEADER true)
\copy (SELECT * FROM analytics.dim_location)            TO 'tableau/data/dim_location.csv'            WITH (FORMAT csv, HEADER true)

-- Facts
\copy (SELECT * FROM analytics.fct_purchase_order_lines) TO 'tableau/data/fct_purchase_order_lines.csv' WITH (FORMAT csv, HEADER true)
\copy (SELECT * FROM analytics.fct_sales_order_lines)    TO 'tableau/data/fct_sales_order_lines.csv'    WITH (FORMAT csv, HEADER true)
\copy (SELECT * FROM analytics.fct_stock_movements)      TO 'tableau/data/fct_stock_movements.csv'      WITH (FORMAT csv, HEADER true)
\copy (SELECT * FROM analytics.fct_product_inventory)    TO 'tableau/data/fct_product_inventory.csv'    WITH (FORMAT csv, HEADER true)

\echo Export complete.
