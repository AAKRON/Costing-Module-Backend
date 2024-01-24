class BlanksLocationPrice < ApplicationRecord
    has_one :blanks
    has_one :locations

    include Upsertable
    include Paginatable
    include Searchable
end
