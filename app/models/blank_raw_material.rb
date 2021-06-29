# frozen_string_literal: true
class BlankRawMaterial < ApplicationRecord
  belongs_to :blank
  belongs_to :raw_material

  validates_presence_of :piece_per_unit_of_measure
end
