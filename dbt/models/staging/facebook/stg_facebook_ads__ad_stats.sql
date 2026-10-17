-- Path: /dbt/models/staging/facebook/stg_facebook_ads__ad_stats.sql
-- Grain: one row per ad_id and ad_date.

WITH source_data AS (

    SELECT * FROM {{ source('facebook_ads', 'ad_stats') }}

),

formatted AS (
    -- Formatting columns
    SELECT
        CAST(ad_id AS STRING)                               AS ad_id,
        CAST(account_id AS STRING)                          AS account_id,
        CAST(ad_date AS DATE)                               AS ad_date,
        
        CAST(ad_spend AS DECIMAL(18, 6))                    AS spend,
        
        CAST(NULLIF(ad_impressions, 'null') AS BIGINT)      AS impressions,
        
        CAST(NULLIF(ad_clicks, 'null') AS BIGINT)           AS clicks_raw        
    FROM source_data
),

/*
    Business rules from the source profile:
    -- Facebook omits zero-valued metrics, so missing clicks mean 0.
    -- Rows with no spend, no impressions and no clicks carry no information.
*/

cleaned (
    SELECT
        'facebook'              AS platform,
        ad_id,
        account_id,
        ad_date,
        spend,
        COALESCE(impressions, 0)    AS impressions,
        COALESCE(clicks_raw, 0)     AS clicks,
        clicks_raw IS NOT NULL      AS is_clicks_reported
    FROM formatted
    WHERE NOT (
        spend = 0
        and COALESCE(impressions, 0) = 0
        and COALESCE(clicks_raw, 0) = 0
    )
)

SELECT * FROM cleaned
