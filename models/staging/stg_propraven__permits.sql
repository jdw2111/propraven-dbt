{{
  config(
    materialized = 'view',
    tags = ['propraven', 'staging', 'permits']
  )
}}

with source as (
    select * from {{ source('propraven_silver', 'PERMIT') }}
),

renamed as (
    select
        PRPV_PERMIT_ID         as permit_id,
        PRPV_PARCEL_ID         as parcel_id,
        PERMIT_NUMBER          as permit_number,
        PERMIT_TYPE            as permit_type,
        PERMIT_STATUS          as permit_status,
        PERMIT_CLASS           as permit_class,
        DESCRIPTION            as description,
        ESTIMATED_COST         as estimated_cost_usd,
        FILED_DATE             as filed_date,
        ISSUED_DATE            as issued_date,
        FINALED_DATE           as finaled_date,
        CONTRACTOR_NAME        as contractor_name,
        APPLICANT_NAME         as applicant_name,
        JURISDICTION_ID        as jurisdiction_id,
        LAST_REFRESHED_AT      as last_refreshed_at
    from source
)

select * from renamed
