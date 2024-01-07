class Location < ApplicationRecord
    validates_presence_of :name

    include Upsertable
    include Paginatable
    include Searchable
end
