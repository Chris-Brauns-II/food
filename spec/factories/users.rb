FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    sub { Faker::Internet.uuid }

    trait :with_person do
      person_id { SecureRandom.uuid }
    end
  end
end
