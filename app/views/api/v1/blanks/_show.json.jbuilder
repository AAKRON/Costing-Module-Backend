# frozen_string_literal: true
job_price_cost = 0.0
job_inventory_cost = 0.0
blank_average_cost = 0.0

json.id blank.id
json.blank_number blank.blank_number
json.description blank.description
json.blank_type blank.blank_type.description
json.cost blank.cost.round(5)
json.blank_type_id blank.blank_type.id
json.type_number blank.blank_type.type_number
json.jobs do
  json.array! blank.blank_jobs do |job|
    job = BlankJobDecorator.new(job)
    json.job_number job.job_number
    json.description job.description
    json.wages_per_hour job.wages_per_hour
    json.hour_per_piece job.hour_per_piece.round(5)
    json.direct_labor_cost job.direct_labor_cost
    json.overhead_inventory_cost job.overhead_inventory_cost
    json.overhead_pricing_cost job.overhead_pricing_cost
    json.job_listing_id job.job_listing_id
    json.total_inventory_cost job.total_inventory_cost.round(5)
    json.total_pricing_cost job.total_pricing_cost.round(5)
    job_price_cost = job_price_cost + job.total_pricing_cost.to_f
    job_inventory_cost = job_inventory_cost + job.total_inventory_cost.to_f
  end
end

json.job_price_cost job_price_cost.round(5)
json.job_inventory_cost job_inventory_cost.round(5)

blank_average_cost_by_blank_id = BlankAverageCost.find_by_blank_id(blank.blank_number)

unless blank_average_cost_by_blank_id.nil?
  blank_average_cost = blank_average_cost_by_blank_id.average_cost_of_blank
end

json.blank_average_cost blank_average_cost.round(5)

total_price_cost = job_price_cost.round(5) + blank_average_cost.round(5)
json.total_price_cost total_price_cost.round(5)

total_inventory_cost = job_inventory_cost.round(5) + blank_average_cost.round(5)
json.total_inventory_cost total_inventory_cost.round(5)
