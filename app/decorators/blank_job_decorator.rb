class BlankJobDecorator < SimpleDelegator
  def job_number
    job_listing.job_number
  end

  def description
    job_listing.description
  end

  def wages_per_hour
    job_listing.wages_per_hour || BigDecimal('0')
  end

  def direct_labor_cost
   Cost::DirectLabor.new(wages_per_hour, hour_per_piece).value
  end

  def overhead_inventory_cost
    Cost::InventoryOverhead.new(direct_labor_cost).value
  end

  def overhead_pricing_cost
    Cost::PricingOverhead.new(direct_labor_cost).value
  end

  def total_inventory_cost
    direct_labor_cost.to_f + overhead_inventory_cost.to_f
  end

  def total_pricing_cost
    direct_labor_cost.to_f + overhead_pricing_cost.to_f
  end
end
