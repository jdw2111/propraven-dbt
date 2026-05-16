{{
  config(
    materialized = 'view',
    tags = ['propraven', 'staging', 'parcels']
  )
}}

-- Renamed + lower-cased view over the shared SILVER.PARCEL table.
-- Drop this in your own dbt project and downstream models can ref it as
--   {{ ref('stg_propraven__parcels') }}
-- without touching the upstream marketplace share directly.

with source as (
    select * from {{ source('propraven_silver', 'PARCEL') }}
),

renamed as (
    select
        PRPV_PARCEL_ID            as parcel_id,
        PRPV_GEOGRAPHY_ID         as geography_id,
        APN                       as apn,
        STATE_FIPS                as state_fips,
        COUNTY_FIPS               as county_fips,
        LOT_SIZE_ACRES            as lot_size_acres,
        LATITUDE                  as latitude,
        LONGITUDE                 as longitude,
        OWNER_OCCUPIED            as owner_occupied,
        ABSENTEE_OWNER            as absentee_owner,
        LAST_REFRESHED_AT         as last_refreshed_at
    from source
)

select * from renamed
