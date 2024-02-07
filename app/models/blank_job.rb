class BlankJob < ApplicationRecord
  include Paginatable
  include Upsertable

  belongs_to :blank, required: true
  belongs_to :job_listing, required: true
  attr_accessor :location_id
end
