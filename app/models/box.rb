# frozen_string_literal: true

class Box < ApplicationRecord
  has_many :item_boxes
  has_many :item

  validates_presence_of :name
  validates_presence_of :cost_per_box

  include Upsertable
  include Paginatable
  include Searchable

  def self.listing_csv
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma
      csv << ["ID", "NAME", "COST PER BOX"]
      all.each do |result|
        csv << result.attributes.values_at(*["id", "name", "cost_per_box"])
      end
    end
  end

  def self.listing_xlsx(boxes)
    p = Axlsx::Package.new
    wb = p.workbook
  
    wb.add_worksheet(name: "Boxes") do |sheet|
      sheet.add_row ["ID", "NAME", "COST PER BOX"]
      boxes.each do |result|
        sheet.add_row [result.id, result.name, result.cost_per_box]
      end
    end
  
    p.to_stream.read
  end
  
 
end
