-- fct_product_inventory: grain = on-hand quantity per (product, location).
-- A snapshot-style fact; gives dim_location a fact to join to.
WITH inventory AS (
    SELECT * FROM {{ ref('stg_production__product_inventory') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['product_id', 'location_id']) }} AS product_inventory_key,
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
        {{ dbt_utils.generate_surrogate_key(['location_id']) }} AS location_key,
        product_id,
        location_id,
        shelf,
        bin,
        quantity
    FROM inventory
)

SELECT * FROM final
