-- Path: /dbt/models/staging/snapchat/stg_snapchat_ads__ads.sql
-- Grain: one row per ad_id.

WITH source_data AS (

    SELECT * FROM {{ source('snapchat_ads', 'ads') }}

),

formatted AS (
    -- Formatting columns
    SELECT
        CAST(ad_id AS STRING)                       AS ad_id,
        CAST(ad_group_id AS STRING)                 AS ad_group_id,
        CAST(ad_name AS STRING)                     AS ad_name,

        CAST(ad_detail_updated_at AS TIMESTAMP)     AS ad_updated_at
    FROM source_data
)

SELECT * FROM formatted