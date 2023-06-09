{{
   config(
    materialized='incremental',
    incremental_strategy = 'insert_overwrite',
    cluster_by = ["query"],
    )
}}
{%- call set_sql_header(config) %}
  {{ milliseconds_to_readable_time_udf() }}
{%- endcall %}
SELECT
  query,
  (SELECT APPROX_TOP_SUM() FROM UNNEST(project_ids) AS project_ids,
  APPROX_TOP_COUNT(reservation_id, 100) AS reservation_ids,
  APPROX_TOP_COUNT(user_email, 100) AS user_emails,
  COUNTIF(cache_hit) / COUNT(*) AS cache_hit_ratio,
  SUM(query_cost) AS total_query_cost,
  SUM(total_slot_ms) AS total_slot_ms,
  MILLISECONDS_TO_READABLE_TIME_UDF(SUM(total_slot_ms), 2) AS total_slot_time,
  COUNT(*) AS amount
FROM
  {{ ref('most_repeated_jobs_incremental') }}
GROUP BY query
HAVING amount > 1
ORDER BY amount DESC
LIMIT {{ var('output_limit_size') }}
