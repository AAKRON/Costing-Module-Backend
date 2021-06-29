# frozen_string_literal: true
class Box < ApplicationRecord
  include Upsertable
  include Paginatable
  include Searchable

  has_many :item_boxes
  has_many :item

  validates_presence_of :name
  validates_presence_of :cost_per_box
end
