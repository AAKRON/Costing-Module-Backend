class BoxesLocationPrice < ApplicationRecord
    has_one :boxes
    has_one :locations


    scope :filter_by_location, ->(location_id, _order, _start, _limit, id, cost_per_box, name) {
        where_clauses = "WHERE TRUE "
        where_clauses = "#{where_clauses} AND id::text LIKE '#{id}%'" unless id.blank?
        where_clauses = "#{where_clauses} AND cost_per_box::text LIKE '#{cost_per_box}%'" unless cost_per_box.blank?
        where_clauses = "#{where_clauses} AND name LIKE '#{name}%'" unless name.blank?

        find_by_sql("SELECT * FROM get_boxes(#{location_id}) #{where_clauses};")
    }
end
