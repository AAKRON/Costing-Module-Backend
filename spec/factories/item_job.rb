FactoryBot.define do
  factory :item_job do |f|
    f.hour_per_piece { Faker::Number.number 1 }
    job_listing
    item
  end
end
