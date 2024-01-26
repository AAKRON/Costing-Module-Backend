class ColorsLocationPrice < ApplicationRecord
    has_one :colors
    has_one :locations

    include Upsertable
    include Paginatable
    include Searchable
end
