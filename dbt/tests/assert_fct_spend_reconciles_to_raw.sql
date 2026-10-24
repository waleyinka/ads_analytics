-- Path: tests/assert_fct_spend_reconciles_to_raw.sql

-- Fails if total spend per platform in the fact table differs from raw by
-- more than 1 cent. Proves no step (filter, join, union, incremental merge)
-- dropped or duplicated money.

with raw_spend as (

    select 'facebook' as platform, sum(cast(ad_spend as decimal(18, 6))) as spend
    from {{ source('facebook_ads', 'ad_stats') }}

    union all

    select 'snapchat', sum(cast(ad_spend as decimal(18, 6)))
    from {{ source('snapchat_ads', 'ad_stats') }}

),

fct_spend as (

    select platform, sum(spend) as spend
    from {{ ref('fct_ad_performance_daily') }}
    group by platform

)

select
    raw_spend.platform,
    raw_spend.spend                        as raw_spend,
    fct_spend.spend                        as fct_spend,
    raw_spend.spend - fct_spend.spend      as difference
from raw_spend
full outer join fct_spend
    on raw_spend.platform = fct_spend.platform
where abs(coalesce(raw_spend.spend, 0) - coalesce(fct_spend.spend, 0)) > 0.01