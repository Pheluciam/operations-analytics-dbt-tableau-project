-- dim_vendor: one row per supplier we buy from.
WITH vendors AS (
    SELECT * FROM {{ ref('stg_purchasing__vendor') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['vendor_id']) }} AS vendor_key,
        vendor_id,
        account_number,
        vendor_name,
        credit_rating,
        preferred_vendor_status,
        active_flag
    FROM vendors
)

SELECT * FROM final
