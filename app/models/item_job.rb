# frozen_string_literal: true
class ItemJob < ApplicationRecord
  include Paginatable
  include Upsertable

  belongs_to :item, required: true
  belongs_to :job_listing, required: true

  validates :hour_per_piece, presence: true

  validates :job_listing_id, uniqueness: { scope: :item_id, message: "An item can only have one job type. Please select another job type." }
  
end
