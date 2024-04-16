class ScreensLocationPrice < ApplicationRecord
    has_one :screens
    has_one :locations

    scope :filter_by_location, ->(location_id, _order, _start, _limit, id, cost, screen_id) {
        where_clauses = "WHERE TRUE "
        where_clauses = "#{where_clauses} AND id::text LIKE '#{id}%'" unless id.blank?
        where_clauses = "#{where_clauses} AND cost::text LIKE '#{cost}%'" unless cost.blank?
        where_clauses = "#{where_clauses} AND id::text LIKE '#{screen_id}%'" unless screen_id.blank?

        find_by_sql("SELECT * FROM get_screens(#{location_id}) #{where_clauses};")
    }

    scope :filter_screens_id_by_location, ->(location_id) {
        find_by_sql("SELECT * FROM get_screens(#{location_id}) ORDER BY id;")
    }
end
