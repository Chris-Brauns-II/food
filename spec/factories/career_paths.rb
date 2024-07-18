FactoryBot.define do
  factory :career_path do
    id { SecureRandom.uuid }
    job

    title { Faker::Number.number(digits: 1) }
    lower_limit { Faker::Number.number(digits: 1) }
    upper_limit { Faker::Number.number(digits: 1) }
    order { 0 }
  end
end
