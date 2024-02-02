class AppConstantsView < ApplicationRecord
    include Paginatable
    include Searchable

    scope :filter_by_location, ->(location_id, params) {
        find_by_sql("SELECT * FROM get_app_constants(#{location_id});")
    }
end
