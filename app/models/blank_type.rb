class BlankType < ApplicationRecord
  include Upsertable
  include Paginatable

  validates :type_number, :description, presence: true
  validates :type_number, uniqueness: true
  has_many :blanks, class_name: 'Blank', primary_key: 'id', foreign_key: :type_number

  before_save { |record| record.id = type_number}
end
