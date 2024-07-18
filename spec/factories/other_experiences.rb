FactoryBot.define do
  factory :other_experience do
    id { SecureRandom.uuid }
    seeker

    organization_name { Faker::Company.name }
    position { "Welder" }
    start_date { Faker::Date.between(from: 10.years.ago, to: 5.years.ago) }
    end_date { Faker::Date.between(from: 5.years.ago, to: 1.year.ago) }
    is_current { false }
    description { Faker::Lorem.paragraph }
  end
end
