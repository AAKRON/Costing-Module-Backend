class ItemWithBlankPerCostView < ApplicationRecord
  include Paginatable
  include Searchable

   scope :filter_by_location, ->(location_id, _start, _limit, item_number) {
        where_clauses = "WHERE TRUE "
        where_clauses = "#{where_clauses} AND item_number::text LIKE '#{item_number}%'" unless item_number.blank?

        find_by_sql("SELECT * FROM get_blanks_listing_item_with_costs(#{location_id}) #{where_clauses} LIMIT #{_limit} OFFSET #{_start};;")
    }
end
