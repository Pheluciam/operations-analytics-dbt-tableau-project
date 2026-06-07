-- fct_sales_order_lines: grain = one outbound sales-order line.
-- Joins sales detail to its header for customer + order dates. gross_amount is
-- list extended; net_amount applies the line discount (AdventureWorks LineTotal).
WITH order_lines AS (
    SELECT * FROM {{ ref('stg_sales__sales_order_detail') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_sales__sales_order_header') }}
),

joined AS (
    SELECT
        d.sales_order_detail_id,
        d.sales_order_id,
        h.customer_id,
        d.product_id,
        h.order_date,
        h.due_date,
        h.ship_date,
        h.status AS order_status,
        h.online_order_flag,
        d.order_qty,
        d.unit_price,
        d.unit_price_discount
    FROM order_lines AS d
    INNER JOIN orders AS h
        ON d.sales_order_id = h.sales_order_id
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['sales_order_detail_id']) }} AS sales_order_line_key,
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_key,
        sales_order_detail_id,
        sales_order_id,
        customer_id,
        product_id,
        order_date,
        due_date,
        ship_date,
        order_status,
        online_order_flag,
        order_qty,
        unit_price,
        unit_price_discount,
        {{ extended_amount('order_qty', 'unit_price') }} AS gross_amount,
        {{ extended_amount('order_qty', 'unit_price', 'unit_price_discount') }} AS net_amount
    FROM joined
)

SELECT * FROM final
