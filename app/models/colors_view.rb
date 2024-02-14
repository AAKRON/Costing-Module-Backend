class ColorsView < ApplicationRecord
    include Paginatable
    include Searchable

    scope :filter_by_location, ->(location_id, _order, _start, _limit, params) {
        cost_of_color = (params.fetch(:cost_of_color, '') == 'null' ) ? '' : params.fetch(:cost_of_color, '')

        where_clauses = "WHERE TRUE "
        where_clauses = "#{where_clauses} AND LOWER(name) LIKE LOWER('#{params[:name]}%')" unless params.fetch(:name, '').empty?
        where_clauses = "#{where_clauses} AND LOWER(code) LIKE LOWER('#{params[:code]}%')" unless params.fetch(:code, '').empty?
        where_clauses = "#{where_clauses} AND cost_of_color::text LIKE '#{cost_of_color}%'" unless cost_of_color.blank?

        find_by_sql("SELECT * FROM get_colors(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
    }
end
