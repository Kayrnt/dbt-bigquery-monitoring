{{
   config(
    materialized='incremental',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
      "field": "hour",
      "data_type": "timestamp",
      "granularity": "hour"
    },
    cluster_by = ["user_email"],
    partition_expiration_days = var('lookback_window_days')
    )
}}
SELECT
  hour,
  user_email,
  SUM(query_cost) AS total_query_cost,
  SUM(total_slot_ms) AS total_slot_ms,
  COUNT(*) AS query_count
FROM {{ ref('jobs_incremental') }}
GROUP BY hour, user_email
