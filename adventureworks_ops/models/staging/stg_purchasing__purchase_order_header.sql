-- Staging: purchasing.purchaseorderheader → one row per inbound PO raised.
-- Rename + recast date columns to DATE (timestamps are date-grained here).
WITH source AS (
    SELECT * FROM {{ source('purchasing', 'purchaseorderheader') }}
),

renamed AS (
    SELECT
        purchaseorderid        AS purchase_order_id,
        revisionnumber         AS revision_number,
        status                 AS status,
        employeeid             AS employee_id,
        vendorid               AS vendor_id,
        shipmethodid           AS ship_method_id,
        orderdate::DATE        AS order_date,
        shipdate::DATE         AS ship_date,
        subtotal               AS subtotal,
        taxamt                 AS tax_amount,
        freight                AS freight,
        modifieddate           AS modified_date
    FROM source
)

SELECT * FROM renamed
