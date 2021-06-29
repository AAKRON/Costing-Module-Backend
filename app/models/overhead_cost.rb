# frozen_string_literal: true
class OverheadCost < ApplicationRecord
  belongs_to :overhead_percentage
  belongs_to :job_listing

  validates :overhead_percentage_id, presence: true
  validates :job_listing_id, presence: true
end
