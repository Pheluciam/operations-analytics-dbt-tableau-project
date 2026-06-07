-- dim_customer: one row per customer we sell to. customer_type derived from
-- whether the customer is a store (reseller) or an individual person.
WITH customers AS (
    SELECT * FROM {{ ref('stg_sales__customer') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_key,
        customer_id,
        person_id,
        store_id,
        territory_id,
        CASE
            WHEN store_id IS NOT NULL THEN 'Store'
            WHEN person_id IS NOT NULL THEN 'Individual'
            ELSE 'Unknown'
        END AS customer_type
    FROM customers
)

SELECT * FROM final
