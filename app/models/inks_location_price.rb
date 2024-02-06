class InksLocationPrice < ApplicationRecord
    has_one :inks
    has_one :locations


    scope :filter_by_location, ->(location_id, _order, _start, _limit, id, ink_cost, name) {
        where_clauses = "TRUE "
        where_clauses = "#{where_clauses} AND id::text LIKE '#{id}%'" unless id.blank?
        where_clauses = "#{where_clauses} AND ink_cost::text LIKE '#{ink_cost}%'" unless ink_cost.blank?
        where_clauses = "#{where_clauses} AND name LIKE '#{name}%'" unless name.blank?

        find_by_sql("SELECT * FROM get_inks(#{location_id});")
    }
end
