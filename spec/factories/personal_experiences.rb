FactoryBot.define do
  factory :personal_experience do
    id { SecureRandom.uuid }
    seeker

    activity { "Babysitting" }
    start_date { Time.zone.local(2019, 1, 1) }
    end_date { Time.zone.local(2020, 1, 1) }
    description { "I babysat for my neighbor's kids." }
  end
end
