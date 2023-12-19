class Ink < ApplicationRecord
    has_many :item

    validates_presence_of :name
    validates_presence_of :ink_cost

    include Upsertable
    include Paginatable
    include Searchable
end
