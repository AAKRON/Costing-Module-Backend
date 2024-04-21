class RawMaterialView < ApplicationRecord
  include Paginatable
  include Searchable

  scope :filter_by_location, ->(location_id, _order, _start, _limit, cost, name, raw_material_type, vendor, unit, color) {
    where_clauses = "WHERE TRUE "
    where_clauses = "#{where_clauses} AND cost::text LIKE '#{cost}%'" unless cost.blank?
    where_clauses = "#{where_clauses} AND LOWER(name) LIKE LOWER('#{name}%')" unless name.blank?
    where_clauses = "#{where_clauses} AND LOWER(raw_material_type) LIKE LOWER('#{raw_material_type}%')" unless raw_material_type.blank?
    where_clauses = "#{where_clauses} AND LOWER(vendor) LIKE LOWER('#{vendor}%')" unless vendor.blank?
    where_clauses = "#{where_clauses} AND LOWER(unit) LIKE LOWER('#{unit}%')" unless unit.blank?
    where_clauses = "#{where_clauses} AND LOWER(color) LIKE LOWER('#{color}%')" unless color.blank?

    find_by_sql("SELECT * FROM get_raw_materials(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
  }

  scope :filter_raw_materials_by_location, ->(location_id, ids) {
    where_clauses = "WHERE TRUE "
    where_clauses = "#{where_clauses} AND id IN (#{ids})" unless ids.blank?

    find_by_sql("SELECT * FROM get_raw_materials(#{location_id}) #{where_clauses} ORDER BY id;")
  }

  def self.listing_csv(scope)
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma

      csv << ["ID", "NAME", "RAW MATERIAL TYPE", "VENDOR", "COST", "UNIT", "COLOR"]
      scope.each do |result|
        csv << result.attributes.values_at(*["id", "name", "raw_material_type", "vendor","cost","unit","color"])
      end
    end
  end
end
