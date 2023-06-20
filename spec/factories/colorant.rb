FactoryBot.define do
  factory :colorant do |f|
    description { Faker::StarWars.quote }
    cost { Faker::Number.number 1 }
  end
end
