FactoryBot.define do
  factory :user do |f|
    username { Faker::GameOfThrones.house }
    role { 'admin' }
  end
end
