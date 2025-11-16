{% test min_rows(model, min_value) %}

select
  count(*) as row_count
from {{ model }}
having count(*) < {{ min_value }}

{% endtest %}
