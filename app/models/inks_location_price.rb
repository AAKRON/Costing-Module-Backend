class InksLocationPrice < ApplicationRecord
    has_one :inks
    has_one :locations


    scope :filter_by_location, ->(location_id, _order, _start, _limit, id, ink_cost, name) {
        where_clauses = "WHERE TRUE "
        where_clauses = "#{where_clauses} AND id::text LIKE '#{id}%'" unless id.blank?
        where_clauses = "#{where_clauses} AND ink_cost::text LIKE '#{ink_cost}%'" unless ink_cost.blank?
        where_clauses = "#{where_clauses} AND LOWER(name) LIKE LOWER('#{name}%')" unless name.blank?

        find_by_sql("SELECT * FROM get_inks(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
    }
end
