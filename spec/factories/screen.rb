FactoryBot.define do
  factory :screen do |f|
    f.screen_size { ['small', 'medium', 'large'].shuffle.first }
    f.cost { Faker::Number.number(digits: 2) }
  end
end
