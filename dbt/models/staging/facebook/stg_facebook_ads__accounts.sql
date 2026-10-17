-- Path: /dbt/models/staging/facebook/stg_facebook_ads__accounts.sql
-- Grain: one row per account_id.

WITH source_data AS (

    SELECT * FROM {{ source('facebook_ads', 'accounts') }}

),

formatted AS (
    -- Formatting columns
    SELECT
        CAST(account_id AS STRING)              AS account_id,
        CAST(account_name AS STRING)            AS account_name,
        
        CAST(ad_currency_code AS STRING)        AS ad_currency_code,
        
        CAST(account_created_at AS TIMESTAMP)   AS account_created_at,
        CAST(account_updated_at AS TIMESTAMP)   AS account_updated_at
    FROM source_data
)

SELECT * FROM formatted
