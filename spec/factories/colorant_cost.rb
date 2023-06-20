FactoryBot.define do
  factory :colorant_cost do |f|
    colorant_percentage { Faker::Number.number 1 }
    cost { Faker::Number.number 1 }
    blank
    colorant
  end
end
