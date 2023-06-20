FactoryBot.define do
  factory :box do |f|
    name { Faker::GameOfThrones.house }
    cost_per_unit { Faker::Number.number 1 }
  end
end
