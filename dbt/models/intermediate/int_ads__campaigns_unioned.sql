-- Grain: one row per platform and campaign_id.
-- Job: combine both platforms' campaigns into one shape for dim_campaign.
-- Expected rows: 4,162 (Facebook) + 109 (Snapchat) = 4,271.

WITH facebook_campaigns AS (

    SELECT
        campaign_id,
        campaign_name
    FROM {{ ref('stg_facebook_ads__campaigns') }}

),

-- Facebook campaigns have no account_id column, so derived from ads.
facebook_campaign_accounts AS (
    SELECT DISTINCT campaign_id, account_id
    FROM {{ ref('stg_facebook_ads__ads') }}
),

facebook AS (
    SELECT
        'facebook'                                   AS platform,
        fc.campaign_id,
        fc.campaign_name,
        fca.account_id
    FROM facebook_campaigns fc
    LEFT JOIN facebook_campaign_accounts fca
        ON fc.campaign_id = fca.campaign_id
),

snapchat AS (
    SELECT
        'snapchat'                                   AS platform,
        campaign_id,
        campaign_name,
        account_id
    FROM {{ ref('stg_snapchat_ads__campaigns') }}
),

unioned AS (
    SELECT
        platform,
        campaign_id,
        campaign_name,
        account_id
    FROM facebook
    UNION ALL
    SELECT
        platform,
        campaign_id,
        campaign_name,
        account_id
    FROM snapchat
)

SELECT * FROM unioned