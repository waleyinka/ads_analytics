-- Path: /dbt/models/staging/snapchat/stg_snapchat_ads__ad_groups.sql
-- Grain: one row per ad_group_id.

with source_data as (

    select * from {{ source('snapchat_ads', 'ad_groups') }}

),

formatted as (
    -- Formatting columns
    select

        cast(ad_group_id as string)            as ad_group_id,
        cast(campaign_id as string)            as campaign_id,
        cast(ad_group_name as string)          as ad_group_name,

        cast(ad_group_updated_at as timestamp) as ad_group_updated_at
    from source_data
),

deduped as (
    select *
    from formatted
    qualify row_number() over (
        partition by ad_group_id
        order by ad_group_updated_at desc
    ) = 1
)

select * from deduped
