-- Grain: one row per platform and campaign.

with campaigns as (

    select * from {{ ref('int_ads__campaigns_unioned') }}

),

facebook_accounts as (

    select
        account_id,
        account_name
    from {{ ref('stg_facebook_ads__accounts') }}

),

spend_summary as (

    select
        platform,
        campaign_id,
        min(ad_date) as first_spend_date,
        max(ad_date) as last_spend_date
    from {{ ref('int_ads__ad_stats_unioned') }}
    where spend > 0
    group by platform, campaign_id

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['c.platform', 'c.campaign_id']) }} as campaign_key,
        c.platform,
        c.campaign_id,
        c.campaign_name,
        c.account_id,
        -- Snapchat has no account names in the source.
        f.account_name,
        ss.first_spend_date,
        ss.last_spend_date,
        ss.campaign_id is not null                                                  as has_spend
    from campaigns as c
    left join facebook_accounts as f
        on
            c.platform = 'facebook'
            and c.account_id = f.account_id
    left join spend_summary as ss
        on
            c.platform = ss.platform
            and c.campaign_id = ss.campaign_id

)

select * from final
