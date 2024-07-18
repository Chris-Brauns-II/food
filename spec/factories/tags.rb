FactoryBot.define do
  factory :tag do
    id { SecureRandom.uuid }

    name { Faker::Lorem.word }
  end
end
