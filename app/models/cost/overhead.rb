module Cost
  class Overhead
    attr_reader :direct_labor_cost

    def initialize(direct_labor_cost)
      @direct_labor_cost = BigDecimal(direct_labor_cost)
    end
  end
end
