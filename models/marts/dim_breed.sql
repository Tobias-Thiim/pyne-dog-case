{{ config(materialized='table') }}

with base as (
    select
        breed_id,
        breed_name,
        temperament,
        breed_group,
	bred_for
    from {{ ref('stg_dog_breeds') }}
)

select *
from base
order by breed_name
