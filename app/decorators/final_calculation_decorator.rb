class FinalCalculationDecorator < SimpleDelegator
    def initialize(final_calculation)
        @final_calculation = final_calculation
    end

    def raw_material_cost
        if @final_calculation.location_id.present?
            raw_materials_location = RawMaterialsLocationPrice.where(raw_materials_id: @final_calculation.raw_material.id).where(locations_id: @final_calculation.location_id).first
            if raw_materials_location.present?
                return raw_materials_location[:cost]
            end
        end
        return @final_calculation.raw_material.cost
    end

    def raw_calculated
        (raw_material_cost / @final_calculation.number_of_pieces_per_unit_one).round(5)
    end

    def color_one_cost
        if @final_calculation.colorant_one != ''
            color = Color.where(name: @final_calculation.colorant_one)[0]
            if color.present?
                if @final_calculation.location_id.present?
                    colors_location = ColorsLocationPrice.where(colors_id: color.id).where(locations_id: @final_calculation.location_id).first
                    if colors_location.present?
                        return colors_location[:cost_of_color]
                    end
                end
            end
            return color.try(:cost_of_color) || 0.0
        end
        return 0.0
    end

    def color_two_cost
        if @final_calculation.colorant_two != ''
            color = Color.where(name: @final_calculation.colorant_two)[0]
            if color.present?
                if @final_calculation.location_id.present?
                    colors_location = ColorsLocationPrice.where(colors_id: color.id).where(locations_id: @final_calculation.location_id).first
                    if colors_location.present?
                        return colors_location[:cost_of_color]
                    end
                end
            end
            return color.try(:cost_of_color) || 0.0
        end
        return 0.0
    end

    def blank_final_calculations_view
        _location_id = @location ? @location.id : 0
        _order = "id ASC"
        _start = 0
        _limit = 1000
        return BlankFinalCalculationsView.filter_by_location(_location_id, _order, _start, _limit, nil, nil, @final_calculation.blank_id, nil)
    end

    def blank_average_cost
        BlankAverageCost.find_by_blank_id(@final_calculation.blank_id).try(:average_cost_of_blank) || 0.0
    end
end
