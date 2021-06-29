# frozen_string_literal: true
module Upsertable
  extend ActiveSupport::Concern

  module ClassMethods
    def bulk_update_or_create_many(array_of_hash)
      Upsert.batch(connection, table_name.to_sym) do |upsert|
        array_of_hash.each.with_index do |record|
          record.each do |data| 
            upsert.row({cell_key: data[:cell_key]}, data.merge({
              created_at: Time.zone.now,
              updated_at: Time.zone.now
            })) 
          end
        end
      end
    end

    def bulk_update_or_create(array_of_hashes, key, key_as_id: true)

      Upsert.batch(connection, table_name.to_sym) do |upsert|
        array_of_hashes.each do |hash|
          unique_column = Hash[key, hash[key], :id, hash[key]]
          unique_column = Hash[key, hash[key]] unless key_as_id
          upsert.row(unique_column, hash.merge({
            created_at: Time.zone.now,
            updated_at: Time.zone.now
          }))
        end
      end
    end
  end
end
