FactoryBot.define do
  factory :manufactured_blank do |f|
    f.description { Faker::Shakespeare.hamlet[0] }
    f.blank_number { Faker::Number.number 1 }
  end
end
