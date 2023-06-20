FactoryBot.define do
  factory :job_listing do |f|
    sequence(:job_number)
    f.description { Faker::Lorem.sentence }
    f.wages_per_hour { Faker::Number.number(digits: 1) }
    screen
  end
end
