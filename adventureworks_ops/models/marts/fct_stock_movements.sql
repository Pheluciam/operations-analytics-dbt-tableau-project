-- fct_stock_movements: grain = one stock-movement ledger entry.
-- transaction_type is P (purchase), S (sales) or W (work order).
-- cost_amount is the extended cost of the movement.
--
-- Materialized INCREMENTAL: transactionhistory is an append-only dated ledger, so
-- after the first full load dbt only processes movements on/after the latest
-- transaction_date already present. delete+insert on transaction_id keeps re-runs
-- idempotent (reprocessing the boundary day replaces those rows, never duplicates).
-- Forward-only by design; `dbt build --full-refresh` rebuilds from scratch.
{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='transaction_id'
    )
}}

WITH movements AS (
    SELECT * FROM {{ ref('stg_production__transaction_history') }}

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
