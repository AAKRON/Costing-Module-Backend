# frozen_string_literal: true
class OverheadPercentage < ApplicationRecord
  has_many :overhead_costs

  enum type: [:inventory, :pricing]
end
