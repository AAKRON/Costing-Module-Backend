class Vendor < ApplicationRecord
  has_many :raw_materials

  include Paginatable
  include Searchable

  def self.bulk_update_or_create(array)
    Upsert.batch(connection, table_name.to_sym) do |upsert|
      array.each do |data|
        upsert.row(name: data, code: data,
                   created_at: Time.zone.now, updated_at: Time.zone.now)
      end
    end
  end
end
