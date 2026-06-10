-- Staging: production.transactionhistoryarchive → archived stock movements
-- (2011-04 to 2013-07; pre-archive of the rolling ~1-year live ledger).
-- Identical schema + rename treatment as stg_production__transaction_history;
-- the two are UNION ALLed in fct_stock_movements (IDs never overlap).
WITH source AS (
    SELECT * FROM {{ source('production', 'transactionhistoryarchive') }}
),

renamed AS (
    SELECT
        transactionid           AS transaction_id,
        productid               AS product_id,
        referenceorderid        AS reference_order_id,
        referenceorderlineid    AS reference_order_line_id,
        transactiondate::DATE   AS transaction_date,
        transactiontype         AS transaction_type,
        quantity                AS quantity,
        actualcost              AS actual_cost,
        modifieddate            AS modified_date
    FROM source
)

SELECT * FROM renamed
