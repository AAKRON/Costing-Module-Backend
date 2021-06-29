FactoryGirl.define do
  factory :material_cost do |f|
    ink_cost Faker::Number.number 1
    box_cost_per_item Faker::Number.number 1
    screen_size_cost Faker::Number.number 1
    item
  end
end
