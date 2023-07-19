class BlanksListingItemWithCost < ApplicationRecord
  include Paginatable
  include Searchable
  include Upsertable

  belongs_to :blank, foreign_key: :blank_number
  before_save { |record| record.cell_key = item_number + blank_number }
end
