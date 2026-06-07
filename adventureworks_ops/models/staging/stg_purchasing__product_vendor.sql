-- Staging: purchasing.productvendor → which vendor supplies which product,
-- with lead time and cost terms. Grain: one row per (product, vendor).
WITH source AS (
    SELECT * FROM {{ source('purchasing', 'productvendor') }}
),

renamed AS (
    SELECT
        productid          AS product_id,
        businessentityid   AS vendor_id,
        averageleadtime    AS average_lead_time,
        standardprice      AS standard_price,
        lastreceiptcost    AS last_receipt_cost,
        lastreceiptdate    AS last_receipt_date,
        minorderqty        AS min_order_qty,
        maxorderqty        AS max_order_qty,
        onorderqty         AS on_order_qty,
        unitmeasurecode    AS unit_measure_code,
        modifieddate       AS modified_date
    FROM source
)

SELECT * FROM renamed
