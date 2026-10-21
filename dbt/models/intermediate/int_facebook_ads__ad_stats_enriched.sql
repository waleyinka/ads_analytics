-- Path: models/intermediate/int_facebook_ads__ad_stats_enriched.sql
-- Grain: one row per ad_id and ad_date (Facebook).

WITH stats AS (
    SELECT *
    FROM {{ ref('stg_facebook_ads__ad_stats') }}
),

ads AS (
    SELECT
       ad_id,
       campaign_id,
       ad_group_id
    FROM {{ ref('stg_facebook_ads__ads') }}
),

accounts AS (
    SELECT
        account_id,
        ad_currency_code
    FROM {{ ref('stg_facebook_ads__accounts') }}
),

joined AS (
    SELECT
        CAST(s.platform AS STRING)               AS platform,
        CAST(s.ad_id AS STRING)                  AS ad_id,
        CAST(s.ad_date AS DATE)                  AS ad_date,
        CAST(a.campaign_id AS STRING)            AS campaign_id,
        CAST(a.ad_group_id AS STRING)            AS ad_group_id,
        CAST(ac.ad_currency_code AS STRING)      AS currency_code,
        CAST(s.spend AS DECIMAL(18, 6))          AS spend,
        CAST(s.impressions AS BIGINT)            AS impressions,
        CAST(s.clicks AS BIGINT)                 AS clicks,
        CAST(s.is_clicks_reported AS BOOLEAN)    AS is_clicks_reported
    FROM stats s
    LEFT JOIN ads a
        ON s.ad_id = a.ad_id
    LEFT JOIN accounts ac
        ON s.account_id = ac.account_id
)

SELECT * FROM joined
