# frozen_string_literal: true
class ColorantCost < ApplicationRecord
  belongs_to :blank
  belongs_to :colorant

  validates_presence_of :colorant_percentage
end
