{{
  config(
    materialized = 'view',
    tags = ['propraven', 'staging', 'geography']
  )
}}

with source as (
    select * from {{ source('propraven_silver', 'GEOGRAPHY') }}
),

renamed as (
    select
        PRPV_GEOGRAPHY_ID  as geography_id,
        STATE_FIPS         as state_fips,
        STATE_NAME         as state_name,
        COUNTY_FIPS        as county_fips,
        COUNTY_NAME        as county_name,
        CBSA_CODE          as cbsa_code,
        CBSA_NAME          as cbsa_name,
        CENSUS_TRACT_GEOID as census_tract_geoid,
        CENSUS_BLOCK_GEOID as census_block_geoid
    from source
)

select * from renamed
