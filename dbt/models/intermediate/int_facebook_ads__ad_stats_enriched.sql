-- Path: models/intermediate/int_facebook_ads__ad_stats_enriched.sql
-- Grain: one row per ad_id and ad_date (Facebook).

with stats as (
    select *
    from {{ ref('stg_facebook_ads__ad_stats') }}
),

ads as (
    select
        ad_id,
        campaign_id,
        ad_group_id
    from {{ ref('stg_facebook_ads__ads') }}
),

accounts as (
    select
        account_id,
        ad_currency_code
    from {{ ref('stg_facebook_ads__accounts') }}
),

joined as (
    select
        cast(s.platform as string)            as platform,
        cast(s.ad_id as string)               as ad_id,
        cast(s.ad_date as date)               as ad_date,
        cast(a.campaign_id as string)         as campaign_id,
        cast(a.ad_group_id as string)         as ad_group_id,
        cast(ac.ad_currency_code as string)   as currency_code,
        cast(s.spend as decimal(18, 6))       as spend,
        cast(s.impressions as bigint)         as impressions,
        cast(s.clicks as bigint)              as clicks,
        cast(s.is_clicks_reported as boolean) as is_clicks_reported
    from stats as s
    left join ads as a
        on s.ad_id = a.ad_id
    left join accounts as ac
        on s.account_id = ac.account_id
)

select * from joined
