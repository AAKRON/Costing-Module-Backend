class ItemType < ApplicationRecord
  include Upsertable
  include Paginatable

  has_many :items, class_name: 'Item', primary_key: 'id', foreign_key: :type_number
end
