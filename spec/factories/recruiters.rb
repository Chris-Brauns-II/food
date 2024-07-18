FactoryBot.define do
  factory :recruiter do
    id { SecureRandom.uuid }
    employer_id { SecureRandom.uuid }

    user
  end
end
