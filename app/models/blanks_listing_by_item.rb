class BlanksListingByItem < ApplicationRecord
  include Paginatable
  include Searchable
  include Upsertable

  before_save { |record| record.cell_key = item_number + blank_number }
end
