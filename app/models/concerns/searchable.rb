module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search(keyword, field)
      where("lower(#{field.to_s}::text) LIKE ?", "#{keyword.downcase}%")
    end
  end
end
