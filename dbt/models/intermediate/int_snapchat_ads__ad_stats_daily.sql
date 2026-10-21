-- Path: models/intermediate/int_snapchat_ads__ad_stats_daily.sql
-- Grain: one row per ad_id and ad_date (Snapchat).

-- Modelled as an ephemeral instead of being built in the warehouse since it is compiled
-- into and used only by int_snapchat_ads__ad_stats_enriched, so it is compiled
-- into that model as a CTE 
{{ config(materialized='ephemeral') }}

WITH stats AS (
    SELECT *
    FROM {{ ref('stg_snapchat_ads__ad_stats') }}
),

aggregated AS (
    SELECT
        platform,
        ad_id,
        ad_date,
        currency_code,                               -- always EUR; safe to group by
        SUM(spend)                                   AS spend,
        SUM(impressions)                             AS impressions,
        SUM(clicks)                                  AS clicks,
        
        -- TRUE only if every country reported clicks for this ad-day.
        BOOL_AND(is_clicks_reported)                 AS is_clicks_reported,
        
        COUNT(*)                                     AS country_count
    FROM stats
    GROUP BY
        platform,
        ad_id,
        ad_date,
        currency_code
)

SELECT * FROM aggregated