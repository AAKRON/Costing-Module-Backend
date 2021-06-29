select
  jl.id,
  jl.description,
  jl.job_number,
  s.screen_size,
  jl.screen_id,
  jl.wages_per_hour
from job_listings jl
left join screens s
on s.id=jl.screen_id
