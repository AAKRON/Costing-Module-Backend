FactoryGirl.define do
  factory :screen do |f|
    f.screen_size 'small'
    f.cost Faker::Number.number 2
  end
end
