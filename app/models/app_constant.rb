class AppConstant < ApplicationRecord
  include Paginatable
  include Searchable

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :value, presence: true

  DECIMAL_PLACE = '%.5f'

  def self.find_by_name(name)
    name = name.to_s
    constant = where(name: name)
    raise ActiveRecord::RecordNotFound if constant.empty?
    constant.first.value if constant
  end
end
