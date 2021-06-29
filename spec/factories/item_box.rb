FactoryGirl.define do
  factory :item_box do
    pieces_per_box Faker::Number.number 1
    box
    item
  end
end
