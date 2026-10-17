-- Path: /dbt/models/staging/snapchat/stg_snapchat_ads__ad_stats.sql
-- Grain: one row per ad_id, ad_date and country_code.

WITH source_data AS (

    SELECT * FROM {{ source('snapchat_ads', 'ad_stats') }}

),

formatted AS (
    -- Formatting columns
    SELECT
        CAST(ad_detail_id AS STRING)                        AS ad_id,
        CAST(ad_date AS DATE)                               AS ad_date,
        CAST(ad_country AS STRING)                          AS country_code,
        CAST(ad_currency_code AS STRING)                    AS currency_code,
        
        CAST(ad_spend AS DECIMAL(18, 6))                    AS spend,

        CAST(ad_impressions AS BIGINT)                      AS impressions,
        
        CAST(NULLIF(ad_clicks, 'null') AS BIGINT)           AS clicks_raw
    FROM source_data
),

cleaned AS (
    SELECT
        'snapchat'                  AS platform,
        ad_id,
        ad_date,
        country_code,
        currency_code,
        spend,
        impressions,
        COALESCE(clicks_raw, 0)     AS clicks,
        clicks_raw IS NOT NULL      AS is_clicks_reported
    FROM formatted
)

SELECT * FROM cleaned