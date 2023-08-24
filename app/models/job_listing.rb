# frozen_string_literal: true
class JobListing < ApplicationRecord
  include Paginatable
  include Searchable

  has_many :overhead_costs
  has_many :item_jobs
  belongs_to :screen, optional: true

  validates :job_number, :description, presence: true
  validates :job_number, uniqueness: true

  before_save { |record| record.id = job_number}

  def self.bulk_update_or_create(array_of_hash)
    @lookup = Hash[Screen.all.pluck(:screen_size, :id)]
    Upsert.batch(self.connection, self.table_name.to_sym) do |upsert|
      array_of_hash.each do |data|
        upsert.row({id: data[:job_number], job_number: data[:job_number]},
				   {description: data[:description], wages_per_hour: data[:wages_per_hour],
                    screen_id: data[:screen_size].nil? ? nil : @lookup[data[:screen_size].strip],
                    created_at: Time.zone.now, updated_at: Time.zone.now})
      end
    end
  end

  def self.listing_xlsx(jobs)
    p = Axlsx::Package.new
    wb = p.workbook
  
    wb.add_worksheet(name: "Jobs") do |sheet|
      sheet.add_row ["ID", "DESCRIPTION", "WAGES_PER_HOUR"]
      jobs.each do |result|
        sheet.add_row [result.id, result.description, result.wages_per_hour]
      end
    end
  
    p.to_stream.read
  end
  
end
