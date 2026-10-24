-- Path: /dbt/models/staging/facebook/stg_facebook_ads__ad_groups.sql
-- Grain: one row per ad_group_id

with source_data as (

    select * from {{ source('facebook_ads', 'ad_groups') }}

),

formatted as (
    -- Formatting columns
    select
        cast(ad_group_id as string)            as ad_group_id,
        cast(ad_group_name as string)          as ad_group_name,

        cast(ad_group_updated_at as timestamp) as updated_at
    from source_data
)

select * from formatted
