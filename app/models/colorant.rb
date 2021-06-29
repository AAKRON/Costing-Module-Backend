# frozen_string_literal: true
class Colorant < ApplicationRecord
  has_many :colorant_costs

  validates_presence_of :description
  validates_presence_of :cost
end
