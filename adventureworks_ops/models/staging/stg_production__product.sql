-- Staging: production.product → product / SKU master.
-- Rename to snake_case, recast lifecycle dates to DATE, drop rowguid.
WITH source AS (
    SELECT * FROM {{ source('production', 'product') }}
),

renamed AS (
    SELECT
        productid               AS product_id,
        name                    AS product_name,
        productnumber           AS product_number,
        makeflag                AS make_flag,
        finishedgoodsflag       AS finished_goods_flag,
        color                   AS color,
        safetystocklevel        AS safety_stock_level,
        reorderpoint            AS reorder_point,
        standardcost            AS standard_cost,
        listprice               AS list_price,
        size                    AS size,
        sizeunitmeasurecode     AS size_unit_measure_code,
        weightunitmeasurecode   AS weight_unit_measure_code,
        weight                  AS weight,
        daystomanufacture       AS days_to_manufacture,
        productline             AS product_line,
        class                   AS class,
        style                   AS style,
        productsubcategoryid    AS product_subcategory_id,
        productmodelid          AS product_model_id,
        sellstartdate::DATE     AS sell_start_date,
        sellenddate::DATE       AS sell_end_date,
        discontinueddate::DATE  AS discontinued_date,
        modifieddate            AS modified_date
    FROM source
)

SELECT * FROM renamed
