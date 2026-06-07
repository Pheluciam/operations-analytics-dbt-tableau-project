-- Staging: production.productinventory → on-hand qty per (product, location).
-- Grain: one row per (product_id, location_id). Drop rowguid.
WITH source AS (
    SELECT * FROM {{ source('production', 'productinventory') }}
),

renamed AS (
    SELECT
        productid      AS product_id,
        locationid     AS location_id,
        shelf          AS shelf,
        bin            AS bin,
        quantity       AS quantity,
        modifieddate   AS modified_date
    FROM source
)

SELECT * FROM renamed
