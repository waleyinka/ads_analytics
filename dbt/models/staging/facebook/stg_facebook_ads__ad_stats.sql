-- Path: /dbt/models/staging/facebook/stg_facebook_ads__ad_stats.sql
-- Grain: one row per ad_id and ad_date.

with source_data as (

    select * from {{ source('facebook_ads', 'ad_stats') }}

),

formatted as (
    -- Formatting columns
    select
        cast(ad_id as string)                          as ad_id,
        cast(account_id as string)                     as account_id,
        cast(ad_date as date)                          as ad_date,

        cast(ad_spend as decimal(18, 6))               as spend,

        cast(nullif(ad_impressions, 'null') as bigint) as impressions,

        cast(nullif(ad_clicks, 'null') as bigint)      as clicks_raw
    from source_data
),

/*
    Business rules from the source profile:
    -- Facebook omits zero-valued metrics, so missing clicks mean 0.
    -- Rows with no spend, no impressions and no clicks carry no information.
*/

cleaned (
    select
        'facebook'               as platform,
        ad_id,
        account_id,
        ad_date,
        spend,
        coalesce(impressions, 0) as impressions,
        coalesce(clicks_raw, 0)  as clicks,
        clicks_raw is not null   as is_clicks_reported
    from formatted
    where not (
        spend = 0
        and coalesce(impressions, 0) = 0
        and coalesce(clicks_raw, 0) = 0
    )
)

select * from cleaned
