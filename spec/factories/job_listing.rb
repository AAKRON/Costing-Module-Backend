FactoryBot.define do
  factory :job_listing do |f|
    sequence(:job_number)
    f.description { Faker::Shakespeare.hamlet[0] }
    f.wages_per_hour { Faker::Number.number 1 }
    screen
  end
end
