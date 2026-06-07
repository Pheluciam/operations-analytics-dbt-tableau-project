-- Staging: production.productlistpricehistory → dated list-price changes.
-- Natural SCD source for the Phase 3 snapshot. Grain: (product, start_date).
WITH source AS (
    SELECT * FROM {{ source('production', 'productlistpricehistory') }}
),

renamed AS (
    SELECT
        productid        AS product_id,
        startdate::DATE  AS start_date,
        enddate::DATE    AS end_date,
        listprice        AS list_price,
        modifieddate     AS modified_date
    FROM source
)

SELECT * FROM renamed
