# frozen_string_literal: true
class RawMaterial < ApplicationRecord
  include Paginatable

  validates :name, uniqueness: true

  belongs_to :units_of_measure, optional: true
  belongs_to :color, optional: true
  belongs_to :rawmaterialtype, optional: true
  belongs_to :vendor, optional: true
end
