-- Path: models/marts/reporting/marketing_performance_daily.sql
-- Grain: one row per platform, campaign and day.

WITH fct AS (

    SELECT * FROM {{ ref('fct_ad_performance_daily') }}

),

campaigns AS (

    SELECT campaign_key, campaign_name, account_id, account_name
    FROM {{ ref('dim_campaign') }}

),

dates AS (

    SELECT date_day, week_start, month_start, year
    FROM {{ ref('dim_date') }}

),

-- Roll ads up to campaign x day. Additive measures are summed; ratios are
-- NOT computed here: they must come from the totals, never averaged.
-- currency_code is safe in the GROUP BY: a campaign belongs to one account,
-- and an account has one currency. The uniqueness test proves it.
campaign_daily AS (

    SELECT
        platform,
        campaign_key,
        campaign_id,
        ad_date,
        currency_code,
        SUM(spend)                                   AS spend,
        SUM(spend_eur)                               AS spend_eur,
        SUM(impressions)                             AS impressions,
        SUM(clicks)                                  AS clicks,
        COUNT(DISTINCT ad_id)                        AS active_ads
    FROM fct
    GROUP BY platform, campaign_key, campaign_id, ad_date, currency_code

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['cd.campaign_key', 'cd.ad_date']) }}   AS campaign_day_key,
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
        CAST(cd.spend AS decimal(18, 2))         AS spend,
        CAST(cd.spend_eur AS decimal(18, 2))     AS spend_eur,
        cd.impressions,
        cd.clicks,
        cd.active_ads,

        -- Ratios from this row's totals. NULLIF turns a zero denominator into
        -- NULL ("undefined") instead of an error or a misleading 0.
        CAST(cd.clicks AS double)
            / NULLIF(cd.impressions, 0)                          AS ctr,
        CAST(cd.spend_eur
            / NULLIF(cd.clicks, 0) AS decimal(18, 4))            AS cpc_eur,
        CAST(cd.spend_eur * 1000
            / NULLIF(cd.impressions, 0) AS decimal(18, 4))       AS cpm_eur

    FROM campaign_daily cd
    LEFT JOIN campaigns c
        ON cd.campaign_key = c.campaign_key
    LEFT JOIN dates
        on cd.ad_date = dates.date_day

)

select * from final