-- Grain: one row per platform and campaign.

WITH campaigns AS (

    SELECT * FROM {{ ref('int_ads__campaigns_unioned') }}

),

facebook_accounts AS (

    SELECT account_id, account_name
    FROM {{ ref('stg_facebook_ads__accounts') }}

),

spend_summary AS (

    SELECT
        platform,
        campaign_id,
        min(ad_date)                                 AS first_spend_date,
        max(ad_date)                                 AS last_spend_date
    FROM {{ ref('int_ads__ad_stats_unioned') }}
    WHERE spend > 0
    GROUP BY platform, campaign_id

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['c.platform', 'c.campaign_id']) }} AS campaign_key,
        c.platform,
        c.campaign_id,
        c.campaign_name,
        c.account_id,
        -- Snapchat has no account names in the source.
        f.account_name,
        ss.first_spend_date,
        ss.last_spend_date,
        ss.campaign_id IS NOT NULL        AS has_spend
    FROM campaigns c
    LEFT JOIN facebook_accounts f
        ON c.platform = 'facebook'
       AND c.account_id = f.account_id
    LEFT JOIN spend_summary ss
        ON c.platform = ss.platform
       AND c.campaign_id = ss.campaign_id

)

SELECT * FROM final
