FactoryBot.define do
  factory :training_provider_profile do
    id { SecureRandom.uuid }
    training_provider_id { SecureRandom.uuid }

    user
  end
end
