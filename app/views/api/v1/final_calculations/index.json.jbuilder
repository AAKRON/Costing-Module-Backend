# frozen_string_literal: true
json.array! @final_calculations, partial: 'api/v1/final_calculations/show.json', as: :final_calculation
