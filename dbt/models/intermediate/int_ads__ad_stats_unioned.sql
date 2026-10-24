-- Path: models/intermediate/int_ads__ad_stats_unioned.sql
-- Grain: one row per platform, ad_id and ad_date.

with facebook as (

    select * from {{ ref('int_facebook_ads__ad_stats_enriched') }}

),

snapchat as (

    select * from {{ ref('int_snapchat_ads__ad_stats_enriched') }}

),

fx as (

    select * from {{ ref('int_fx_rates__daily') }}

),

unioned as (

    select
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
    from facebook
    union all
    select
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
    from snapchat

),

converted as (

    select
        u.platform,
        u.ad_id,
        u.ad_date,
        u.campaign_id,
        u.ad_group_id,
        u.currency_code,
        u.spend,
        -- ECB quotes 1 EUR = x USD, so USD -> EUR is a DIVISION.
        -- Multiplying would inflate USD spend by roughly 17%.
        cast(u.spend / fx.units_per_eur as decimal(18, 6)) as spend_eur,
        fx.units_per_eur                                   as fx_units_per_eur,
        u.impressions,
        u.clicks,
        u.is_clicks_reported
    from unioned as u
    left join fx
        on
            u.currency_code = fx.currency_code
            and u.ad_date = fx.rate_date

)

select * from converted
