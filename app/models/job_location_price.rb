class JobLocationPrice < ApplicationRecord
    has_one :job_listings
    has_one :locations

    include Upsertable
    include Paginatable
    include Searchable
end
