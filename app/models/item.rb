# frozen_string_literal: true
class Item < ApplicationRecord
  belongs_to :box
  before_save { |record| record.id = item_number}

  include Paginatable
  include Searchable
  include Upsertable

  validates :item_number, :description, presence: true
  validates :item_number, uniqueness: true

  has_many :item_jobs
  has_many :blanks
  has_many :item_boxes
  has_many :material_costs
  has_many :blanks_listing_item_with_cost, :foreign_key => :item_number
  belongs_to :item_type, class_name: ItemType, primary_key: 'type_number', foreign_key: :item_type_id, optional: true

  accepts_nested_attributes_for :item_jobs

  def box_cost
    
    unless box.nil?
    (box.cost_per_box.to_f) /  (number_of_pcs_per_box == 0 ? 1 : number_of_pcs_per_box)
    #(box.cost_per_box.to_f) / number_of_pcs_per_box
    else
      0
    end
  end

end
