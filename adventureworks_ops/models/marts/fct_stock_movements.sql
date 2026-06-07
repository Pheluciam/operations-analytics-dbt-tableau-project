-- fct_stock_movements: grain = one stock-movement ledger entry.
-- transaction_type is P (purchase), S (sales) or W (work order).
-- cost_amount is the extended cost of the movement.
WITH movements AS (
    SELECT * FROM {{ ref('stg_production__transaction_history') }}
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
