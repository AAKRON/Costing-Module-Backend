class ColorsView < ApplicationRecord
    include Paginatable
    include Searchable

    scope :filter_by_location, ->(location_id, params) {
        cost_of_color = (params.fetch(:cost_of_color, '') == 'null' ) ? '' : params.fetch(:cost_of_color, '')

        where_clauses = "TRUE "
        where_clauses = "#{where_clauses} AND name LIKE '#{params[:name]}%'" unless params.fetch(:name, '').empty?
        where_clauses = "#{where_clauses} AND code LIKE '#{params[:code]}%'" unless params.fetch(:code, '').empty?
        where_clauses = "#{where_clauses} AND cost_of_color::text LIKE '#{cost_of_color}%'" unless cost_of_color.blank?

        find_by_sql("SELECT * FROM get_colors(#{location_id});")
    }
end
