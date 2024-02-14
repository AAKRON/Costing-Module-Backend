class ItemCostView < ApplicationRecord
  include Paginatable
  include Searchable

  scope :filter_by_location, ->(location_id, _order, _start, _limit, item_number, description, type_description, box_name, number_of_pcs_per_box, ink_cost, box_cost, secondary_box_id_exists, secondary_box_cost, total_price_cost, total_inventory_cost) {
    where_clauses = "WHERE TRUE "
    where_clauses = "#{where_clauses} AND item_number::text LIKE '#{item_number}%'" unless item_number.blank?
    where_clauses = "#{where_clauses} AND LOWER(description) LIKE LOWER('%#{description}%')" unless description.blank?
    where_clauses = "#{where_clauses} AND LOWER(type_description) LIKE LOWER('%#{type_description}%')" unless type_description.blank?
    where_clauses = "#{where_clauses} AND LOWER(box_name) LIKE LOWER('#{box_name}%')" unless box_name.blank?
    where_clauses = "#{where_clauses} AND number_of_pcs_per_box::text LIKE '#{number_of_pcs_per_box}%'" unless number_of_pcs_per_box.blank?
    where_clauses = "#{where_clauses} AND ink_cost::text LIKE '#{ink_cost}%'" unless ink_cost.blank?
    where_clauses = "#{where_clauses} AND box_cost::text LIKE '#{box_cost}%'" unless box_cost.blank?
    where_clauses = "#{where_clauses} AND total_price_cost::text LIKE '#{total_price_cost}%'" unless total_price_cost.blank?
    where_clauses = "#{where_clauses} AND total_inventory_cost::text LIKE '#{total_inventory_cost}%'" unless total_inventory_cost.blank?

    if secondary_box_id_exists
        where_clauses = "#{where_clauses} AND secondary_box_cost::text LIKE '#{secondary_box_cost}%'" unless secondary_box_cost.blank?
    end

    find_by_sql("SELECT * FROM get_item_costs(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
  }

  def self.to_price_csv
    CSV.generate(col_sep: ';') do |csv|
      csv << ["Item Number", "Description", "Item Type", "Cost For Price"]
      all.each do |result|
        csv << result.attributes.values_at(*["item_number", "description", "type_description", "total_price_cost"])
      end
    end
  end

  def self.to_invetory_csv
    CSV.generate(col_sep: ';') do |csv|
      csv << ["Item Number", "Description", "Item Type", "Cost For Invetory"]
      all.each do |result|
        csv << result.attributes.values_at(*["item_number", "description", "type_description", "total_inventory_cost"])
      end
    end
  end
end
