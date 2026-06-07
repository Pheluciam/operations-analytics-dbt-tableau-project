-- fct_purchase_order_lines: grain = one inbound purchase-order line.
-- Joins PO detail to its header for vendor + order dates. line_amount and
-- stocked_qty are derived measures (net of rejections).
WITH order_lines AS (
    SELECT * FROM {{ ref('stg_purchasing__purchase_order_detail') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_purchasing__purchase_order_header') }}
),

joined AS (
    SELECT
        d.purchase_order_detail_id,
        d.purchase_order_id,
        h.vendor_id,
        d.product_id,
        h.order_date,
        d.due_date,
        h.ship_date,
        h.status AS order_status,
        d.order_qty,
        d.unit_price,
        d.received_qty,
        d.rejected_qty
    FROM order_lines AS d
    INNER JOIN orders AS h
        ON d.purchase_order_id = h.purchase_order_id
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['purchase_order_detail_id']) }} AS purchase_order_line_key,
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
        {{ dbt_utils.generate_surrogate_key(['vendor_id']) }} AS vendor_key,
        purchase_order_detail_id,
        purchase_order_id,
        vendor_id,
        product_id,
        order_date,
        due_date,
        ship_date,
        order_status,
        order_qty,
        unit_price,
        received_qty,
        rejected_qty,
        order_qty * unit_price AS line_amount,
        received_qty - rejected_qty AS stocked_qty
    FROM joined
)

SELECT * FROM final
