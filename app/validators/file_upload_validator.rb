# frozen_string_literal: true
class FileUploadValidator < ActiveModel::EachValidator
  ALLOWED_CONTENT_TYPES = [
    'application/pdf',
    'image/png',
    'image/jpeg',
    'image/jpg',
    'image/gif',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/csv'
  ].freeze

  MAX_FILE_SIZE = 10.megabytes

  def validate_each(record, attribute, value)
    return if value.nil?

    # Validate content type
    unless ALLOWED_CONTENT_TYPES.include?(value.content_type)
      record.errors.add(attribute, "has an invalid file type. Allowed types: #{ALLOWED_CONTENT_TYPES.join(', ')}")
    end

    # Validate file size
    if value.size > MAX_FILE_SIZE
      record.errors.add(attribute, "is too large. Maximum size is #{MAX_FILE_SIZE / 1.megabyte}MB")
    end

    # Validate filename for malicious content
    if value.original_filename =~ /[<>&"']|\.\.\/|%2e%2e%2f/i
      record.errors.add(attribute, "has an unsafe filename")
    end
  end
end