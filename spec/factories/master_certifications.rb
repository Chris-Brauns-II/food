FactoryBot.define do
  factory :master_certification do
    id { SecureRandom.uuid }

    certification { Faker::Lorem.word }
  end
end
