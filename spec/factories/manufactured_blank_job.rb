FactoryGirl.define do
  factory :manufactured_blank_job do |f|
    f.hour_per_piece Faker::Number.number 1
    job_listing
    manufactured_blank
  end
end
