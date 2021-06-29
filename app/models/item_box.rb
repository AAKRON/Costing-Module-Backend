# frozen_string_literal: true
class ItemBox < ApplicationRecord
  belongs_to :box, optional: true
  belongs_to :item, optional: true

  validates_presence_of :pieces_per_box
end
