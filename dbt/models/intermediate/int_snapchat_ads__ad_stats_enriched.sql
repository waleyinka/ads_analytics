-- Path: models/intermediate/int_snapchat_ads__ad_stats_enriched.sql
-- Grain: one row per ad_id and ad_date (Snapchat).


WITH daily AS (
    SELECT *
    FROM {{ ref('int_snapchat_ads__ad_stats_daily') }}
),

ads AS (

    SELECT ad_id, ad_group_id
    FROM {{ ref('stg_snapchat_ads__ads') }}

),

ad_groups AS (

    -- Already deduplicated in staging (one row per ad_group_id), so this join
    -- can't fan out.
    SELECT ad_group_id, campaign_id
    FROM {{ ref('stg_snapchat_ads__ad_groups') }}
),

joined AS (
    SELECT
        CAST(d.platform AS string)               AS platform,
        CAST(d.ad_id AS string)                  AS ad_id,
        CAST(d.ad_date AS date)                  AS ad_date,
        CAST(ag.campaign_id AS string)           AS campaign_id,
        CAST(a.ad_group_id AS string)            AS ad_group_id,
        CAST(d.currency_code AS string)          AS currency_code,
        CAST(d.spend AS DECIMAL(18, 6))          AS spend,
        CAST(d.impressions AS bigint)            AS impressions,
        CAST(d.clicks AS bigint)                 AS clicks,
        CAST(d.is_clicks_reported AS boolean)    AS is_clicks_reported
    FROM daily d
    LEFT JOIN ads a
        ON d.ad_id = a.ad_id
    LEFT JOIN ad_groups ag
        ON a.ad_group_id = ag.ad_group_id
)

SELECT * FROM joined
