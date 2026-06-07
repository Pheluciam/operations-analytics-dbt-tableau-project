-- Staging: production.transactionhistory → append-only stock-movement ledger
-- (P=purchase, S=sales, W=work order). Source for the Phase 3 incremental model.
WITH source AS (
    SELECT * FROM {{ source('production', 'transactionhistory') }}
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
