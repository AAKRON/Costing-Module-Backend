# frozen_string_literal: true
class Blank < ApplicationRecord
  include Paginatable
  include Searchable
  include Upsertable

  validates :blank_number, :description, presence: true
  validates :blank_number, uniqueness: true
  has_many :blank_jobs
  belongs_to :blank_type, class_name: 'BlankType', primary_key: 'type_number', foreign_key: :blank_type_id, optional: true

  before_save { |record| record.id = blank_number}
end
