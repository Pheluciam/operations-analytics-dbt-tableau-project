-- fct_stock_movements: grain = one stock-movement ledger entry.
-- transaction_type is P (purchase), S (sales) or W (work order).
-- cost_amount is the extended cost of the movement.
--
-- Covers the FULL movement history: the rolling ~1-year live ledger
-- (transactionhistory) UNION ALL the archive (transactionhistoryarchive,
-- 2011-04 to 2013-07). Schemas are identical and transaction IDs never
-- overlap (verified; the unique test on stock_movement_key — derived solely
-- from transaction_id — re-proves it on every build).
--
-- Materialized INCREMENTAL: the ledger is append-only and dated, so after the
-- first full load dbt only processes movements on/after the latest
-- transaction_date already present. delete+insert on transaction_id keeps
-- re-runs idempotent (reprocessing the boundary day replaces those rows,
-- never duplicates). Forward-only by design — archive rows predate the
-- watermark, so adding the archive required a one-off
-- `dbt build --full-refresh`; normal runs stay incremental.
{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='transaction_id'
    )
}}

WITH unioned AS (
    SELECT * FROM {{ ref('stg_production__transaction_history') }}

    UNION ALL

    SELECT * FROM {{ ref('stg_production__transaction_history_archive') }}
),

movements AS (
    SELECT * FROM unioned

    {% if is_incremental() %}
    -- Only the latest slice on incremental runs; delete+insert dedupes the boundary day.
    WHERE transaction_date >= (SELECT MAX(transaction_date) FROM {{ this }})
    {% endif %}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['transaction_id']) }} AS stock_movement_key,
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
        transaction_id,
        product_id,
        reference_order_id,
        reference_order_line_id,
        transaction_date,
        transaction_type,
        quantity,
        actual_cost,
        quantity * actual_cost AS cost_amount
    FROM movements
)

SELECT * FROM final
