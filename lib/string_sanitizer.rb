
class StringSanitizer
  class NoValueError < StandardError; end

  attr_reader :str

  def initialize(str)
    str = str.to_s
    raise NoValueError if str.nil? || str.empty?

    @str = str
  end

  def snakify
    str.downcase.gsub(' ', '_')
  end
end

