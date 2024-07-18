FactoryBot.define do
  factory :webhook do
    name { Faker::Lorem.word }
  end
end
