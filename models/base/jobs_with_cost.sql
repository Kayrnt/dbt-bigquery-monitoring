{{
   config(
    materialized='view'
    )
}}
{{ jobs_with_cost_base("JOBS", contains_query = False) }}
