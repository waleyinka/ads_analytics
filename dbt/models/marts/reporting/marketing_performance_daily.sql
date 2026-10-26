-- Path: models/marts/reporting/marketing_performance_daily.sql
-- Grain: one row per platform, campaign and day.

with fct as (

    select * from {{ ref('fct_ad_performance_daily') }}

),

campaigns as (

    select
        campaign_key,
        campaign_name,
        account_id,
        account_name
    from {{ ref('dim_campaign') }}

),

dates as (

    select
        date_day,
        week_start,
        month_start,
        year
    from {{ ref('dim_date') }}

),

-- Roll ads up to campaign x day. Additive measures are summed; ratios are
-- NOT computed here: they must come from the totals, never averaged.
-- currency_code is safe in the GROUP BY: a campaign belongs to one account,
-- and an account has one currency. The uniqueness test proves it.
campaign_daily as (

    select
        platform,
        campaign_key,
        campaign_id,
        ad_date,
        currency_code,
        sum(spend)            as spend,
        sum(spend_eur)        as spend_eur,
        sum(impressions)      as impressions,
        sum(clicks)           as clicks,
        count(distinct ad_id) as active_ads
    from fct
    group by platform, campaign_key, campaign_id, ad_date, currency_code

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['cd.campaign_key', 'cd.ad_date']) }} as campaign_day_key,
        cd.platform,
        cd.campaign_key,
        cd.campaign_id,
        c.campaign_name,
        c.account_id,
        c.account_name,
        cd.ad_date,
        dates.week_start,
        dates.month_start,
        dates.year,
        cd.currency_code,
        cast(cd.spend as decimal(18, 2))                                          as spend,
        cast(cd.spend_eur as decimal(18, 2))                                      as spend_eur,
        cd.impressions,
        cd.clicks,
        cd.active_ads,

        -- Ratios from this row's totals. NULLIF turns a zero denominator into
        -- NULL ("undefined") instead of an error or a misleading 0.
        cast(cd.clicks as double)
        / nullif(cd.impressions, 0)                                               as ctr,
        cast(
            cd.spend_eur
            / nullif(cd.clicks, 0) as decimal(18, 4)
        )                                                                         as cpc_eur,
        cast(
            cd.spend_eur * 1000
            / nullif(cd.impressions, 0) as decimal(18, 4)
        )                                                                         as cpm_eur

    from campaign_daily as cd
    left join campaigns as c
        on cd.campaign_key = c.campaign_key
    left join dates
        on cd.ad_date = dates.date_day

)

select * from final
