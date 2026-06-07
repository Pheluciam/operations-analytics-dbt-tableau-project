-- Staging: sales.customer → retailer / reseller customers we sell to.
-- Drop rowguid. personid/storeid are nullable (person vs store customers).
WITH source AS (
    SELECT * FROM {{ source('sales', 'customer') }}
),

renamed AS (
    SELECT
        customerid     AS customer_id,
        personid       AS person_id,
        storeid        AS store_id,
        territoryid    AS territory_id,
        modifieddate   AS modified_date
    FROM source
)

SELECT * FROM renamed
