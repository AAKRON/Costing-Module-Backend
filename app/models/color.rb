# frozen_string_literal: true
class Color < ApplicationRecord
  validates_uniqueness_of :name

  has_many :raw_materials

  include Paginatable
  include Searchable

  def self.listing_csv
    CSV.generate(col_sep: ';') do |csv| # Aquí se especifica que el delimitador de campo es el punto y coma

      csv << ["ID", "NAME", "CODE", "COST OF COLOR" ]
      all.each do |result|
        csv << result.attributes.values_at(*["id", "name", "code","cost_of_color"])
      end
    end
  end

  def self.bulk_update_or_create(array)
    Upsert.batch(connection, table_name.to_sym) do |upsert|
      array.each do |data|
        upsert.row(name: data[:name], code: data[:name],
				   cost_of_color: data[:cost_of_color],
                   created_at: Time.zone.now, updated_at: Time.zone.now)
      end
    end
  end
end
