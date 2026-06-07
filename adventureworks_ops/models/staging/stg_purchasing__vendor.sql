-- Staging: purchasing.vendor → one row per supplier we buy from.
-- Light layer only: rename to snake_case, drop the replication rowguid.
WITH source AS (
    SELECT * FROM {{ source('purchasing', 'vendor') }}
),

renamed AS (
    SELECT
        businessentityid          AS vendor_id,
        accountnumber             AS account_number,
        name                      AS vendor_name,
        creditrating              AS credit_rating,
        preferredvendorstatus     AS preferred_vendor_status,
        activeflag                AS active_flag,
        purchasingwebserviceurl   AS purchasing_web_service_url,
        modifieddate              AS modified_date
    FROM source
)

SELECT * FROM renamed
