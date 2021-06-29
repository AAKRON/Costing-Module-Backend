module Cost
  class PricingOverhead < Overhead
    def initialize(direct_labor_cost)
      super(direct_labor_cost)
    end

    def value
      AppConstant::DECIMAL_PLACE % \
        (direct_labor_cost * AppConstant.find_by_name(:price_overhead_percentage).to_f)
    end
  end
end
