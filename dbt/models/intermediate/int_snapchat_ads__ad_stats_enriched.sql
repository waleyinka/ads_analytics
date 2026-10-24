-- Path: models/intermediate/int_snapchat_ads__ad_stats_enriched.sql
-- Grain: one row per ad_id and ad_date (Snapchat).


with daily as (
    select *
    from {{ ref('int_snapchat_ads__ad_stats_daily') }}
),

ads as (

    select
        ad_id,
        ad_group_id
    from {{ ref('stg_snapchat_ads__ads') }}

),

ad_groups as (

    -- Already deduplicated in staging (one row per ad_group_id), so this join
    -- can't fan out.
    select
        ad_group_id,
        campaign_id
    from {{ ref('stg_snapchat_ads__ad_groups') }}
),

joined as (
    select
        cast(d.platform as string)            as platform,
        cast(d.ad_id as string)               as ad_id,
        cast(d.ad_date as date)               as ad_date,
        cast(ag.campaign_id as string)        as campaign_id,
        cast(a.ad_group_id as string)         as ad_group_id,
        cast(d.currency_code as string)       as currency_code,
        cast(d.spend as decimal(18, 6))       as spend,
        cast(d.impressions as bigint)         as impressions,
        cast(d.clicks as bigint)              as clicks,
        cast(d.is_clicks_reported as boolean) as is_clicks_reported
    from daily as d
    left join ads as a
        on d.ad_id = a.ad_id
    left join ad_groups as ag
        on a.ad_group_id = ag.ad_group_id
)

select * from joined
