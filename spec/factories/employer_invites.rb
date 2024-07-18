FactoryBot.define do
  factory :employer_invite do
    id { SecureRandom.uuid }
    employer

    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
