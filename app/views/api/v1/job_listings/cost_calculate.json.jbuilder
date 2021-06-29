# frozen_string_literal: true
wages_per_hour = @job.wages_per_hour || BigDecimal('0')
direct_labor_cost = AppConstant::DECIMAL_PLACE % (Cost::DirectLabor.new(wages_per_hour, @hour_per_piece.to_f).value)
overhead_pricing_cost = AppConstant::DECIMAL_PLACE % (Cost::PricingOverhead.new(direct_labor_cost).value)
total_pricing_cost = direct_labor_cost.to_f + overhead_pricing_cost.to_f

json.job_listing_id @job.job_number
json.job_number @job.job_number
json.description @job.description
json.wages_per_hour wages_per_hour
json.hour_per_piece @hour_per_piece
json.direct_labor_cost direct_labor_cost
json.overhead_pricing_cost overhead_pricing_cost.to_f.round(5)
json.total_pricing_cost total_pricing_cost.round(5)
json.screen @job.screen
