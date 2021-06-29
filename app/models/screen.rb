# frozen_string_literal: true

class Screen < ApplicationRecord
  include Paginatable
  include Searchable
  include Upsertable

  validates :screen_size, presence: true
  validates :cost, presence: true
end
