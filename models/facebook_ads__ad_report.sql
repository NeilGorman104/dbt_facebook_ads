{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with report as (

    select *
    FROM {{ source('tap_facebook', 'basic_ad') }}

), 

accounts as (

    select *
    FROM {{ source('tap_facebook', 'account_history') }}

),

campaigns as (

    select *
    FROM {{ source('tap_facebook', 'campaign_history') }}

),

ad_sets as (

    select *
    FROM {{ source('tap_facebook', 'ad_set_history') }}

),

ads as (

    select *
    FROM {{ source('tap_facebook', 'ad_history') }}

),

joined as (

    select 
        report.date,
        accounts.id as account_id,
        accounts.name as account_name,
        campaigns.id as campaign_id,
        campaigns.name as campaign_name,
        ad_sets.id as ad_set_id,
        ad_sets.name as ad_set_name,
        ads.id as ad_id,
        ads.name as ad_name,
        sum(report.inline_link_clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.spend) as spend

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='facebook_ads__basic_ad_passthrough_metrics', transform = 'sum') }}
    from report 
    left join accounts
        on report.account_id = accounts.id
    left join ads 
        on report.ad_id = ads.id
    left join campaigns
        on ads.campaign_id = campaigns.id
    left join ad_sets
        on ads.ad_set_id = ad_sets.id
    {{ dbt_utils.group_by(9) }}
)

select *
from joined