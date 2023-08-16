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

  def self.listing_xlsx(blanks)
    p = Axlsx::Package.new
    wb = p.workbook
    
    wb.add_worksheet(name: "Blanks Report") do |sheet|
      sheet.add_row ["ID", "DESCRIPTION", "BLANK_TYPE_ID","BLANK TYPE"]
      blanks.each do |result|
       
        begin
          @blank_type = BlankType.find_by(type_number: result.blank_type_id)
          blank_type = @blank_type.description  if @blank_type 
          Rails.logger.info "Blank Type#{@blank_type}"
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.warn "No se encontró el ítem con número: #{result.item_number}"
          blank_type = ''
        end

        sheet.add_row [result.id, result.description, result.blank_type_id,blank_type ]
      end
    end
  
    p.to_stream.read
    end
end
