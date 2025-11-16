{{ config(materialized='table') }}

with base as (
    select
        breed_id,
        breed_name,
        
        -- Weight metric "20 - 35"
        cast(regexp_extract(weight_metric, r'^\s*(\d+)') as int64) as weight_kg_min,
        cast(regexp_extract(weight_metric, r'(\d+)$') as int64)     as weight_kg_max,

        -- Weight imperial "45 - 80"
        cast(regexp_extract(weight_imperial, r'^\s*(\d+)') as int64) as weight_lbs_min,
        cast(regexp_extract(weight_imperial, r'(\d+)$') as int64)     as weight_lbs_max,

        -- Height metric "30 - 60"
        cast(regexp_extract(height_metric, r'^\s*(\d+)') as int64) as height_cm_min,
        cast(regexp_extract(height_metric, r'(\d+)$') as int64)     as height_cm_max,

        -- Lifespan: "10 years", "10 - 15 years", "10 – 15 years"
        cast(regexp_extract(life_span_text, r'^\s*(\d+)') as int64) as lifespan_years_min,
        cast(
            coalesce(
                regexp_extract(life_span_text, r'[-–]\s*(\d+)'),   -- number after a dash / en dash
                regexp_extract(life_span_text, r'(\d+)$')          -- fallback: last number
            ) as int64
        ) as lifespan_years_max

    from {{ ref('stg_dog_breeds') }}
),

enriched as (
    select
        base.*,
        -- Gennemsnitlig forventet levetid
        (lifespan_years_min + lifespan_years_max) / 2.0 as lifespan_years_avg,

        -- Gennemsnitlig vægt i kg
        (weight_kg_min + weight_kg_max) / 2.0 as weight_kg_avg,

        -- Vægtklasser
        case
            when (weight_kg_min + weight_kg_max) / 2.0 < 10 then 'Small'
            when (weight_kg_min + weight_kg_max) / 2.0 < 25 then 'Medium'
            when (weight_kg_min + weight_kg_max) / 2.0 < 40 then 'Large'
            else 'Giant'
        end as weight_class
    from base
)

select *
from enriched
order by breed_name
