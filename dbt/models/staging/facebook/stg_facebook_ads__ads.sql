-- Path: /dbt/models/staging/facebook/stg_facebook_ads__ads.sql
-- Grain: one row per ad_id

with source_data as (

    select * from {{ source('facebook_ads', 'ads') }}

),

formatted as (
    -- Formatting columns
    select
        cast(ad_id as string)            as ad_id,
        cast(campaign_id as string)      as campaign_id,
        cast(ad_group_id as string)      as ad_group_id,
        cast(account_id as string)       as account_id,
        cast(ad_name as string)          as ad_name,

        cast(ad_status as string)        as ad_status,

        cast(ad_updated_at as timestamp) as ad_updated_at
    from source_data
)

select * from formatted
