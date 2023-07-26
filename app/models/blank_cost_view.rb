class BlankCostView < ApplicationRecord
  include Paginatable
  include Searchable

  def self.to_price_csv
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma

      csv << ["Blank Number", "Description", "Blank Type", "Cost For Price"]
      all.each do |result|
        csv << result.attributes.values_at(*["blank_number", "description", "blank_type", "total_blank_cost_for_price"])
      end
    end
  end

  def self.to_invetory_csv
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma

      csv << ["Blank Number", "Description", "Blank Type", "Cost For Invetory"]
      all.each do |result|
        csv << result.attributes.values_at(*["blank_number", "description", "blank_type", "total_blank_cost_for_inventory"])
      end
    end
  end
end
