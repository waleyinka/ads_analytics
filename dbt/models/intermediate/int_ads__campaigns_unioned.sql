-- Grain: one row per platform and campaign_id.
-- Job: combine both platforms' campaigns into one shape for dim_campaign.
-- Expected rows: 4,162 (Facebook) + 109 (Snapchat) = 4,271.

with facebook_campaigns as (

    select
        campaign_id,
        campaign_name
    from {{ ref('stg_facebook_ads__campaigns') }}

),

-- Facebook campaigns have no account_id column, so derived from ads.
facebook_campaign_accounts as (
    select distinct
        campaign_id,
        account_id
    from {{ ref('stg_facebook_ads__ads') }}
),

facebook as (
    select
        'facebook' as platform,
        fc.campaign_id,
        fc.campaign_name,
        fca.account_id
    from facebook_campaigns as fc
    left join facebook_campaign_accounts as fca
        on fc.campaign_id = fca.campaign_id
),

snapchat as (
    select
        'snapchat' as platform,
        campaign_id,
        campaign_name,
        account_id
    from {{ ref('stg_snapchat_ads__campaigns') }}
),

unioned as (
    select
        platform,
        campaign_id,
        campaign_name,
        account_id
    from facebook
    union all
    select
        platform,
        campaign_id,
        campaign_name,
        account_id
    from snapchat
)

select * from unioned
