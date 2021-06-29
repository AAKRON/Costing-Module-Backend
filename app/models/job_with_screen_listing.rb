class JobWithScreenListing < ApplicationRecord
  include Paginatable
  include Searchable
end
