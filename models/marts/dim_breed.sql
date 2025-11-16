{{ config(materialized='table') }}

with base as (
    select
        breed_id,
        breed_name,
        temperament,
        breed_group,
        bred_for
    from {{ ref('stg_dog_breeds') }}
),

enriched as (
    select
        base.*,

        -- Simpel flag for familievenlige racer baseret på temperament-tekst
        case
            when temperament is null then false
            when regexp_contains(lower(temperament), r'(gentle|friendly|affectionate|good with children|playful|kind|patient|loyal)')
                then true
            else false
        end as is_family_friendly

    from base
)

select *
from enriched
order by breed_name
