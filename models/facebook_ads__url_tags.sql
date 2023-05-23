{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with base as (

    select *
    from {{ source('tap_facebook', 'creative_history') }}
), 

required_fields as (

    select
        _fivetran_id,
        id as creative_id,
        url_tags
    from base
    where url_tags is not null
), 

{{ get_url_tags_query() }} 

select *
from fields