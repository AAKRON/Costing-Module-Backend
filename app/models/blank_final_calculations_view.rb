class BlankFinalCalculationsView < ApplicationRecord
  include Paginatable
  include Searchable

  scope :filter_by_location, ->(location_id, _order, _start, _limit, color_description, blank_name, blank_number, raw_material) {
    where_clauses = "WHERE TRUE "
    where_clauses = "#{where_clauses} AND LOWER(color_description) LIKE LOWER('%#{color_description}%')" unless color_description.blank?
    where_clauses = "#{where_clauses} AND LOWER(blank_name) LIKE LOWER('%#{blank_name}%')" unless blank_name.blank?
    where_clauses = "#{where_clauses} AND blank_number::text LIKE '#{blank_number}%'" unless blank_number.blank?
    where_clauses = "#{where_clauses} AND LOWER(raw_material) LIKE LOWER('%#{raw_material}%')" unless raw_material.blank?

    find_by_sql("SELECT * FROM get_blank_final_calculations(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
  }

  scope :get_blank_final_calculations, ->(location_id, blank_number) {
    find_by_sql("SELECT * FROM get_blank_final_calculations(#{location_id}) WHERE blank_number=#{blank_number};")
  }
end
