# frozen_string_literal: true
class ItemBlankJobPiece < ApplicationRecord
  belongs_to :blank
  belongs_to :item_job

  validates_presence_of :hour_per_piece
end
