-- Staging: production.location → warehouse locations / bins holding stock.
WITH source AS (
    SELECT * FROM {{ source('production', 'location') }}
),

renamed AS (
    SELECT
        locationid     AS location_id,
        name           AS location_name,
        costrate       AS cost_rate,
        availability   AS availability,
        modifieddate   AS modified_date
    FROM source
)

SELECT * FROM renamed
