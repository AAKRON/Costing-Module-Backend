class BoxesLocationPrice < ApplicationRecord
    has_one :boxes
    has_one :locations


    scope :filter_by_location, ->(location_id, _order, _start, _limit, id, cost_per_box, name) {
        where_clauses = "WHERE TRUE "
        where_clauses = "#{where_clauses} AND id::text LIKE '#{id}%'" unless id.blank?
        where_clauses = "#{where_clauses} AND cost_per_box::text LIKE '#{cost_per_box}%'" unless cost_per_box.blank?
        where_clauses = "#{where_clauses} AND LOWER(name) LIKE LOWER('#{name}%')" unless name.blank?

        find_by_sql("SELECT * FROM get_boxes(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
    }

    scope :filter_boxes_id_by_location, ->(location_id) {
        find_by_sql("SELECT * FROM get_boxes(#{location_id}) ORDER BY id;")
    }

    scope :get_box_cost, ->(location_id, box_id, number_of_pcs_per_box) {
        box = find_by_sql("SELECT * FROM get_boxes(#{location_id}) WHERE id=#{box_id}").first
        unless box.nil?
            return ((box.cost_per_box.to_f) /  (number_of_pcs_per_box == 0 ? 1 : number_of_pcs_per_box)).round(5)
        end
        return 0
    }
end
