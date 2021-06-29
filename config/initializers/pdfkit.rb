# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  config.wkhtmltopdf = Gem.bin_path("wkhtmltopdf-heroku", "wkhtmltopdf-linux-amd64")
  config.default_options = {
    :page_size => 'Legal',
    :print_media_type => true
  }
end
