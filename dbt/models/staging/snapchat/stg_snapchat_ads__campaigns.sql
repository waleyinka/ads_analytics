-- Path: /dbt/models/staging/snapchat/stg_snapchat_ads__campaigns.sql
-- Grain: one row per campaign_id.

WITH source_data AS (

    SELECT * FROM {{ source('snapchat_ads', 'campaigns') }}

),

formatted AS (
    -- Formatting columns
    SELECT
        CAST(campaign_id AS STRING)                 AS campaign_id,
        CAST(account_id AS STRING)                  AS account_id,
        CAST(campaign_name AS STRING)               AS campaign_name
    FROM source_data
)

SELECT * FROM formatted
