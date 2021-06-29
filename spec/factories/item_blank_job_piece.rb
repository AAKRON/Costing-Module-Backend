FactoryGirl.define do
  factory :item_blank_job_piece do |f|
    f.hour_per_piece Faker::Number.number 1
    item_job
    blank
  end
end
