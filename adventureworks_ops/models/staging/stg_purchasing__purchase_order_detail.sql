-- Staging: purchasing.purchaseorderdetail → inbound PO line items.
-- Grain: one row per purchase_order_detail_id. Amounts derived downstream.
WITH source AS (
    SELECT * FROM {{ source('purchasing', 'purchaseorderdetail') }}
),

renamed AS (
    SELECT
        purchaseorderdetailid   AS purchase_order_detail_id,
        purchaseorderid         AS purchase_order_id,
        productid               AS product_id,
        duedate::DATE           AS due_date,
        orderqty                AS order_qty,
        unitprice               AS unit_price,
        receivedqty             AS received_qty,
        rejectedqty             AS rejected_qty,
        modifieddate            AS modified_date
    FROM source
)

SELECT * FROM renamed
