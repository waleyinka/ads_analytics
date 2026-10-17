-- Path: /dbt/models/staging/snapchat/stg_snapchat_ads__ad_groups.sql
-- Grain: one row per ad_group_id.

WITH source_data AS (

    SELECT * FROM {{ source('snapchat_ads', 'ad_groups') }}

),

formatted AS (
    -- Formatting columns
    SELECT
        
        CAST(ad_group_id AS STRING)                 AS ad_group_id,
        CAST(campaign_id AS STRING)                 AS campaign_id,
        CAST(ad_group_name AS STRING)               AS ad_group_name,

        CAST(ad_group_updated_at AS TIMESTAMP)     AS ad_group_updated_at
    FROM source_data
),

deduped AS (
    SELECT *
    FROM formatted
    QUALIFY row_number() OVER(
        PARTITION BY ad_group_id
        ORDER BY ad_group_updated_at DESC
    ) = 1
)

SELECT * FROM deduped