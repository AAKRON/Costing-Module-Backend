# frozen_string_literal: true
json.id blank.id
json.blank_number blank.blank_number
json.description blank.description
json.number_of_jobs blank.blank_jobs.count
json.jobs do
  json.array! blank.blank_jobs do |job|
    job = BlankJobDecorator.new(job)
    json.job_pk_id job.id
    json.job_number job.job_number
    json.description job.description
    json.wages_per_hour job.wages_per_hour
    json.hour_per_piece job.hour_per_piece.round(5)
    json.direct_labor_cost job.direct_labor_cost
    json.overhead_inventory_cost job.overhead_inventory_cost
    json.overhead_pricing_cost job.overhead_pricing_cost
    json.job_listing_id job.job_listing_id
  end
end
