# config/initializers/pdfkit.rb

PDFKit.configure do |config|
  config.wkhtmltopdf = begin
    Gem.bin_path("wkhtmltopdf-binary", "wkhtmltopdf")
  rescue Gem::GemNotFoundException
    `which wkhtmltopdf`.to_s.strip
  end
end
