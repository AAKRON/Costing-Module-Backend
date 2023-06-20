FactoryBot.define do
  factory :user do |f|
    username { Faker::Lorem.sentence }
    role { 'admin' }
  end
end
