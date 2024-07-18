FactoryBot.define do
  factory :onboarding_session do
    seeker

    id { SecureRandom.uuid }
    started_at { Time.zone.local(2020, 1, 1) }
  end
end
