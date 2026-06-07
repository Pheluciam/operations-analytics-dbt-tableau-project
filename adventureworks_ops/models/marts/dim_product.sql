-- dim_product: one row per product / SKU, with a hashed surrogate key for
-- star-schema joins. is_active_product derived from the lifecycle dates.
WITH products AS (
    SELECT * FROM {{ ref('stg_production__product') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
        product_id,
        product_number,
        product_name,
        product_line,
        class,
        style,
        color,
        size,
        standard_cost,
        list_price,
        safety_stock_level,
        reorder_point,
        make_flag,
        finished_goods_flag,
        sell_start_date,
        sell_end_date,
        discontinued_date,
        (sell_end_date IS NULL AND discontinued_date IS NULL) AS is_active_product
    FROM products
)

SELECT * FROM final
