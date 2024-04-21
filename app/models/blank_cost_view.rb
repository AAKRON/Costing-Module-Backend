class BlankCostView < ApplicationRecord
  include Paginatable
  include Searchable

  scope :filter_by_location, ->(location_id, _order, _start, _limit, blank_number, blank_type_id, description, cost, total_blank_cost_for_price, total_blank_cost_for_inventory) {
    where_clauses = "WHERE TRUE "
    where_clauses = "#{where_clauses} AND blank_number::text LIKE '#{blank_number}%'" unless blank_number.blank?
    where_clauses = "#{where_clauses} AND blank_type_id = #{blank_type_id}" unless blank_type_id.blank?
    where_clauses = "#{where_clauses} AND LOWER(description) LIKE LOWER('#{description}%')" unless description.blank?
    where_clauses = "#{where_clauses} AND cost::text LIKE '#{cost}%'" unless cost.blank?
    where_clauses = "#{where_clauses} AND total_blank_cost_for_price::text LIKE '#{total_blank_cost_for_price}%'" unless total_blank_cost_for_price.blank?
    where_clauses = "#{where_clauses} AND total_blank_cost_for_inventory::text LIKE '#{total_blank_cost_for_inventory}%'" unless total_blank_cost_for_inventory.blank?

    find_by_sql("SELECT * FROM get_blanks(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
  }

  scope :filter_by_blanks_numbers_location, ->(location_id, blank_numbers) {
    where_clauses = "WHERE TRUE "
    where_clauses = "#{where_clauses} AND blank_number IN (#{blank_numbers}%)" unless blank_numbers.blank?

    find_by_sql("SELECT * FROM get_blanks(#{location_id}) #{where_clauses} ORDER BY blank_number;")
  }

  scope :get_blank_by_location, ->(location_id, blank_number) {
    return find_by_sql("SELECT * FROM get_blanks(#{location_id}) WHERE blank_number=#{blank_number}").first
  }

  def self.to_price_csv(scope = nil)
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma

      csv << ["Blank Number", "Description", "Blank Type", "Cost For Price"]
      scope.each do |result|
        csv << result.attributes.values_at(*["blank_number", "description", "blank_type", "total_blank_cost_for_price"])
      end
    end
  end

  def self.to_invetory_csv(scope = nil)
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma

      csv << ["Blank Number", "Description", "Blank Type", "Cost For Invetory"]
      scope.each do |result|
        csv << result.attributes.values_at(*["blank_number", "description", "blank_type", "total_blank_cost_for_inventory"])
      end
    end
  end
end
