{{
  config(
    materialized = 'view',
    tags = ['propraven', 'staging', 'transactions']
  )
}}

-- TRANSACTION = matched deed transfers. A "real sale" is the subset where
-- SALE_PRICE > 0 AND IS_ARM_LENGTH = TRUE. is_sale below is the same
-- definition the parcel.sold webhook uses.

with source as (
    select * from {{ source('propraven_silver', 'TRANSACTION') }}
),

renamed as (
    select
        PRPV_TRANSACTION_ID                                              as transaction_id,
        PRPV_PARCEL_ID                                                   as parcel_id,
        SALE_DATE                                                        as sale_date,
        RECORDING_DATE                                                   as recording_date,
        SALE_PRICE                                                       as sale_price_usd,
        IS_ARM_LENGTH                                                    as is_arm_length,
        coalesce(SALE_PRICE, 0) > 0 and coalesce(IS_ARM_LENGTH, true)    as is_sale,
        DOCUMENT_TYPE                                                    as document_type,
        DOCUMENT_NUMBER                                                  as document_number,
        GRANTOR_NAME                                                     as grantor_name,
        GRANTEE_NAME                                                     as grantee_name,
        GRANTOR_TYPE                                                     as grantor_type,
        GRANTEE_TYPE                                                     as grantee_type,
        LAST_REFRESHED_AT                                                as last_refreshed_at
    from source
)

select * from renamed
