module Cost
  class DirectLabor
    attr_reader :wages_per_hour, :hour_per_piece

    def initialize(wages_per_hour, hour_per_piece = 0)
      @wages_per_hour, @hour_per_piece = wages_per_hour, hour_per_piece
    end

    def value
      AppConstant::DECIMAL_PLACE % (wages_per_hour * hour_per_piece.round(5))
    end
  end
end
