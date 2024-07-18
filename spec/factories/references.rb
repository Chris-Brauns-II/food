FactoryBot.define do
  factory :reference do
    id { SecureRandom.uuid }
    seeker_id { SecureRandom.uuid }

    author_profile_id { SecureRandom.uuid }
    training_provider
    reference_text { "This is a reference" }
  end
end
