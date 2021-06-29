# frozen_string_literal: true
json.id item.id
json.item_number item.item_number
json.description item.description
json.number_of_jobs item.item_jobs.count
json.jobs do
  json.array! item.item_jobs do |job|
    job = ItemJobDecorator.new(job)
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
