# frozen_string_literal: true
class ApplicationJob < ActiveJob::Base
  class Base64StringToSpreadsheet
    def self.perform(base_64_string:, filename:)
      filename = Rails.public_path.join(filename)
      File.delete(filename) if File.exist?(filename)
      File.open(filename, 'wb') do |file|
        file.write(Base64.decode64(base_64_string))
      end

      yield RubyXL::Parser.parse(filename) if block_given?
    end
  end
end
