class RawMaterialView < ApplicationRecord
  include Paginatable
  include Searchable


  def self.listing_csv
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma

      csv << ["ID", "NAME", "RAW MATERIAL TYPE", "VENDOR", "COST", "UNIT", "COLOR"]
      all.each do |result|
        csv << result.attributes.values_at(*["id", "name", "raw_material_type", "vendor","cost","unit","color"])
      end
    end
  end
end
