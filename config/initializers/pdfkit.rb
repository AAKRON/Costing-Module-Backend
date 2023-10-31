# config/initializers/pdfkit.rb

#HEROKU
# PDFKit.configure do |config|
#   config.wkhtmltopdf = Gem.bin_path("wkhtmltopdf-heroku", "wkhtmltopdf-linux-amd64")
#   config.default_options = {
#     :page_size => 'Legal',
#     :print_media_type => true
#   }
# end

PDFKit.configure do |config|
  config.wkhtmltopdf = `which wkhtmltopdf`.to_s.strip
end
