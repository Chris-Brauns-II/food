FactoryBot.define do
  factory :education_experience do
    id { SecureRandom.uuid }
    seeker

    organization_name { Faker::Company.name }
    title { "Student" }
    graduation_date { Faker::Date.between(from: 10.years.ago, to: 5.years.ago) }
    gpa { Faker::Number.decimal(l_digits: 2) }
    activities { Faker::Lorem.paragraph }
  end
end
