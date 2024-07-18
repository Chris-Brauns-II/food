FactoryBot.define do
  factory :employers_employer, class: 'Employers::Employer' do
    employer_id { SecureRandom.uuid }
    name { Faker::Business.name }
    bio { Faker::Company.bs }
    location { Faker::Address.city }
    logo_url { "logo" }
  end
end
