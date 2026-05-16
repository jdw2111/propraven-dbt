{{
  config(
    materialized = 'table',
    tags = ['propraven', 'marts', 'example']
  )
}}

-- Worked example: join parcels to their most recent permit and most recent
-- arm's-length sale. Useful as a starting point for monitoring or scoring.
-- Customize freely — this is a *demonstration* model, not a contract.

with parcels as (
    select * from {{ ref('stg_propraven__parcels') }}
),

latest_permit as (
    select
        parcel_id,
        max(filed_date)               as last_permit_filed_date,
        count(*)                      as lifetime_permit_count
    from {{ ref('stg_propraven__permits') }}
    group by parcel_id
),

latest_sale as (
    select
        parcel_id,
        max(case when is_sale then sale_date end)     as last_sale_date,
        max(case when is_sale then sale_price_usd end) as last_sale_price_usd
    from {{ ref('stg_propraven__transactions') }}
    group by parcel_id
)

select
    p.parcel_id,
    p.apn,
    p.state_fips,
    p.county_fips,
    p.lot_size_acres,
    p.absentee_owner,
    lp.last_permit_filed_date,
    lp.lifetime_permit_count,
    ls.last_sale_date,
    ls.last_sale_price_usd
from parcels p
left join latest_permit lp using (parcel_id)
left join latest_sale  ls using (parcel_id)
