{{
  config(
    materialized = 'view',
    tags = ['propraven', 'staging', 'owners']
  )
}}

with source as (
    select * from {{ source('propraven_silver', 'OWNER') }}
),

renamed as (
    select
        PRPV_PARCEL_ID         as parcel_id,
        PRPV_OWNER_ENTITY_ID   as owner_entity_id,
        OWNER_NAME             as owner_name,
        OWNER_TYPE             as owner_type,
        MAILING_ADDRESS_LINE_1 as mailing_address_line_1,
        MAILING_CITY           as mailing_city,
        MAILING_STATE          as mailing_state,
        MAILING_ZIP            as mailing_zip,
        LAST_REFRESHED_AT      as last_refreshed_at
    from source
)

select * from renamed
