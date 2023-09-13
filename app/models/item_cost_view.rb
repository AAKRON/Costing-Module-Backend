class ItemCostView < ApplicationRecord
  include Paginatable
  include Searchable

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
