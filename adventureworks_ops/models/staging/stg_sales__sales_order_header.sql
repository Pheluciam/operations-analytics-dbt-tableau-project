-- Staging: sales.salesorderheader → one row per outbound sales order.
-- Rename + recast date columns to DATE, drop rowguid.
WITH source AS (
    SELECT * FROM {{ source('sales', 'salesorderheader') }}
),

renamed AS (
    SELECT
        salesorderid             AS sales_order_id,
        revisionnumber           AS revision_number,
        orderdate::DATE          AS order_date,
        duedate::DATE            AS due_date,
        shipdate::DATE           AS ship_date,
        status                   AS status,
        onlineorderflag          AS online_order_flag,
        purchaseordernumber      AS purchase_order_number,
        accountnumber            AS account_number,
        customerid               AS customer_id,
        salespersonid            AS salesperson_id,
        territoryid              AS territory_id,
        billtoaddressid          AS bill_to_address_id,
        shiptoaddressid          AS ship_to_address_id,
        shipmethodid             AS ship_method_id,
        creditcardid             AS credit_card_id,
        creditcardapprovalcode   AS credit_card_approval_code,
        currencyrateid           AS currency_rate_id,
        subtotal                 AS subtotal,
        taxamt                   AS tax_amount,
        freight                  AS freight,
        totaldue                 AS total_due,
        comment                  AS comment,
        modifieddate             AS modified_date
    FROM source
)

SELECT * FROM renamed
