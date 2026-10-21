-- Path: models/intermediate/int_ads__ad_stats_unioned.sql
-- Grain: one row per platform, ad_id and ad_date.

WITH facebook AS (

    SELECT * FROM {{ ref('int_facebook_ads__ad_stats_enriched') }}

),

snapchat AS (

    SELECT * FROM {{ ref('int_snapchat_ads__ad_stats_enriched') }}

),

fx AS (

    SELECT * FROM {{ ref('int_fx_rates__daily') }}

),

unioned AS (

    SELECT 
        platform,
        ad_id,
        ad_date,
        campaign_id,
        ad_group_id,
        currency_code,
        spend,
        impressions,
        clicks,
        is_clicks_reported
    FROM facebook
    UNION ALL
    SELECT
        platform,
        ad_id,
        ad_date,
        campaign_id,
        ad_group_id,
        currency_code,
        spend,
        impressions,
        clicks,
        is_clicks_reported
    FROM snapchat

),

converted AS (

    SELECT
        u.platform,
        u.ad_id,
        u.ad_date,
        u.campaign_id,
        u.ad_group_id,
        u.currency_code,
        u.spend,
        -- ECB quotes 1 EUR = x USD, so USD -> EUR is a DIVISION.
        -- Multiplying would inflate USD spend by roughly 17%.
        CAST(u.spend / fx.units_per_eur AS decimal(18, 6))          AS spend_eur,
        fx.units_per_eur                                            AS fx_units_per_eur,
        u.impressions,
        u.clicks,
        u.is_clicks_reported
    FROM unioned u
    LEFT JOIN fx
        ON u.currency_code = fx.currency_code
       AND u.ad_date = fx.rate_date

)

SELECT * FROM converted