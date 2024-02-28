class ItemJobDecorator < SimpleDelegator
  def job_number
    job_listing.job_number
  end

  def description
    job_listing.description
  end

  def wages_per_hour
    if location_id.present? && location_id != 0
        jobs_location = JobLocationPrice.where(job_listings_id: job_listing.job_number).where(locations_id: location_id).first
        if jobs_location.present?
            return jobs_location[:wages_per_hour].to_f
        end
    end
    return job_listing.wages_per_hour || BigDecimal('0')
  end

  def direct_labor_cost
    Cost::DirectLabor.new(wages_per_hour, hour_per_piece.to_f).value
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

  def screen_location_cost
    if location_id.present? && location_id != 0
        screens_location = ScreensLocationPrice.where(screens_id: job_listing.screen_id).where(locations_id: location_id).first
        if screens_location.present?
            return screens_location[:cost].to_f
        end
    end
    screen = Screen.find(job_listing.screen_id)
    return screen[:cost]
  end
end
