# frozen_string_literal: true
class FilenameSanitizer
  INVALID_FILENAME_CHARS = /[\\\/:\*\?"<>\|]/
  RESERVED_NAMES = %w[CON PRN AUX NUL COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8 COM9 LPT1 LPT2 LPT3 LPT4 LPT5 LPT6 LPT7 LPT8 LPT9].freeze

  def self.sanitize(filename)
    return 'unnamed_file' if filename.nil? || filename.strip.empty?
    
    # Remove directory path
    basename = File.basename(filename)
    
    # Replace invalid characters with underscores
    sanitized = basename.gsub(INVALID_FILENAME_CHARS, '_')
    
    # Remove leading/trailing spaces and dots
    sanitized = sanitized.strip.gsub(/^\.+|\.+$/, '')
    
    # Ensure it's not a reserved Windows filename
    name_without_ext = sanitized.split('.').first.to_s.upcase
    if RESERVED_NAMES.include?(name_without_ext)
      sanitized = "file_#{sanitized}"
    end
    
    # Limit length
    if sanitized.length > 255
      ext = File.extname(sanitized)
      name = File.basename(sanitized, ext)
      sanitized = "#{name[0, 255 - ext.length]}#{ext}"
    end
    
    # Default filename if empty after sanitization
    sanitized.empty? ? 'sanitized_file' : sanitized
  end
end