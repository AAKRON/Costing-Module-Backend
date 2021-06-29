require 'matrix'

module Extractor
  class FieldWide
    include ExcelHelper

    def initialize(spreadsheet)
      @offset_spreadsheet = spreadsheet[3..-1]
      @pointer = Matrix[*Extractor::Base.new(spreadsheet).send(:first_row_cell_values)]
      @job_header = [:job_number, :description, :wages_per_hour, :screen_size]
    end


    def job
      @offset_spreadsheet.map do |row|
        job_cells = row.cells[0..3]
        job_row = job_cells.map { |cell| (cell)? cell.value : nil }
        Hash[@job_header.zip(job_row)]
      end.delete_if { |row| row[:job_number].nil? && row[:description].nil? }
    end

    def spreadsheet_body(main_header:, sparse_cell_header:)
      @offset_spreadsheet.map do |row|
        sparse_cells = row.cells[DATA_RANGE].compact!.to_a
        next if sparse_cells.empty?

        job_number = row.cells.first.value
        map_cells_to_cell_value_and_index(sparse_cells).map! do |first, second|
          cell = @pointer.index(second); cell[1] = 0
          Hash[sparse_cell_header, first.to_f, main_header, @pointer[*cell], 
               :job_listing_id, job_number, :cell_key, job_number.to_s + @pointer[*cell].to_s
          ]
        end
      end.compact
    end

    def body(main_header:, sparse_cell_header:, collection_header:)
      @offset_spreadsheet.map do |row|
        sparse_cells = row.cells[DATA_RANGE].compact!.to_a
        next if sparse_cells.empty?

        sparse_values = map_cells_to_cell_value_and_index(sparse_cells).map! do |first, second|
          cell = @pointer.index(second); cell[1] = 0

          Hash[sparse_cell_header, first, main_header, @pointer[*cell]]
        end

        Hash[:job_number, row.cells.first.value, collection_header, sparse_values]
      end.compact
    end
  end
end
