-- Path: models/intermediate/int_snapchat_ads__ad_stats_daily.sql
-- Grain: one row per ad_id and ad_date (Snapchat).

-- Modelled as an ephemeral instead of being built in the warehouse since it is compiled
-- into and used only by int_snapchat_ads__ad_stats_enriched, so it is compiled
-- into that model as a CTE 
{{ config(materialized='ephemeral') }}

with stats as (
    select *
    from {{ ref('stg_snapchat_ads__ad_stats') }}
),

aggregated as (
    select
        platform,
        ad_id,
        ad_date,
        currency_code,                               -- always EUR; safe to group by
        sum(spend)                   as spend,
        sum(impressions)             as impressions,
        sum(clicks)                  as clicks,

        -- TRUE only if every country reported clicks for this ad-day.
        bool_and(is_clicks_reported) as is_clicks_reported,

        count(*)                     as country_count
    from stats
    group by
        platform,
        ad_id,
        ad_date,
        currency_code
)

select * from aggregated
