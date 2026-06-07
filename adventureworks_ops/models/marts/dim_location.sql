-- dim_location: one row per warehouse location / bin where stock is held.
WITH locations AS (
    SELECT * FROM {{ ref('stg_production__location') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['location_id']) }} AS location_key,
        location_id,
        location_name,
        cost_rate,
        availability
    FROM locations
)

SELECT * FROM final
