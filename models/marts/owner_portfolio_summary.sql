{{
  config(
    materialized = 'table',
    tags = ['propraven', 'marts', 'example']
  )
}}

-- Worked example: roll up parcels by entity, with portfolio size, total
-- assessed value (when the TAX source is present), and recent activity.

with owners as (
    select * from {{ ref('stg_propraven__owners') }}
    where owner_entity_id is not null
),

tax_latest as (
    -- Latest tax-year row per parcel
    select
        PRPV_PARCEL_ID         as parcel_id,
        TAX_YEAR               as tax_year,
        ASSESSED_TOTAL_VALUE   as assessed_total_value,
        row_number() over (
            partition by PRPV_PARCEL_ID
            order by TAX_YEAR desc
        )                      as rn
    from {{ source('propraven_silver', 'TAX') }}
),

tax_latest_filtered as (
    select * from tax_latest where rn = 1
)

select
    o.owner_entity_id,
    any_value(o.owner_name)                       as owner_name_sample,
    count(*)                                       as parcel_count,
    sum(coalesce(t.assessed_total_value, 0))       as total_assessed_value,
    avg(t.assessed_total_value)                    as avg_assessed_value
from owners o
left join tax_latest_filtered t on t.parcel_id = o.parcel_id
group by 1
having count(*) >= 1
order by parcel_count desc
