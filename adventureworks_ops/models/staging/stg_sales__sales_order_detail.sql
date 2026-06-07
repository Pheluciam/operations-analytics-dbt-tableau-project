-- Staging: sales.salesorderdetail → outbound sales-order line items.
-- Grain: one row per sales_order_detail_id. Amounts derived downstream. Drop rowguid.
WITH source AS (
    SELECT * FROM {{ source('sales', 'salesorderdetail') }}
),

renamed AS (
    SELECT
        salesorderdetailid     AS sales_order_detail_id,
        salesorderid           AS sales_order_id,
        productid              AS product_id,
        carriertrackingnumber  AS carrier_tracking_number,
        orderqty               AS order_qty,
        specialofferid         AS special_offer_id,
        unitprice              AS unit_price,
        unitpricediscount      AS unit_price_discount,
        modifieddate           AS modified_date
    FROM source
)

SELECT * FROM renamed
