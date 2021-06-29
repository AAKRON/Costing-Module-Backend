class BlankType < ApplicationRecord
  include Upsertable
  include Paginatable

  has_many :blanks, class_name: Blank, primary_key: 'id', foreign_key: :type_number
end
