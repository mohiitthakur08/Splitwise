FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    mobile_number { Faker::PhoneNumber.cell_phone }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
