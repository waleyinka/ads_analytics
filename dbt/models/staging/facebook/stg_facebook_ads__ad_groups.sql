-- Path: /dbt/models/staging/facebook/stg_facebook_ads__ad_groups.sql
-- Grain: one row per ad_group_id

WITH source_data AS (

    SELECT * FROM {{ source('facebook_ads', 'ad_groups') }}

),

formatted AS (
    -- Formatting columns
    SELECT
        CAST(ad_group_id AS STRING)             AS ad_group_id,
        CAST(ad_group_name AS STRING)           AS ad_group_name,

        CAST(ad_group_updated_at AS TIMESTAMP)  AS updated_at
    FROM source_data
)

SELECT * FROM formatted
