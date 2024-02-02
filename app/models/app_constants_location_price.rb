class AppConstantsLocationPrice < ApplicationRecord
    has_one :app_constant
    has_one :locations

    include Upsertable
    include Paginatable
    include Searchable
end
