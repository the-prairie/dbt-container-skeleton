with
source as (

    select *
    from {{ source('raw', 'raw_companies') }}
),

renamed as (

    select
        cast(id as integer) as id,
        _airbyte_ab_id,
        name,
        growth_stage,
        company_status,
        total_jobs_available,
        founders_score_cumulated,
        _airbyte_raw_companies_hashid as row_id,
        timestamp(create_date) as created_at,
        total_funding * 1000000 as total_funding_to_date,
        timestamp(_airbyte_emitted_at) as updated_at
    from source
)

select *
from renamed