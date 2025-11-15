with raw as (

    select *
    from `pyne-dogs-ttm.bronze.dog_api_raw`

)

select
    id                  as breed_id,
    name                as breed_name,
    life_span           as life_span_text,
    temperament,
    weight__metric      as weight_metric,
    height__metric      as height_metric,
    weight__imperial    as weight_imperial,
    height__imperial    as height_imperial,
    bred_for,
    breed_group,
    origin,
    country_code,
    description,
    history,
    reference_image_id,
    _dlt_load_id,
    _dlt_id
from raw
