FactoryBot.define do
  factory :job_freshness_context do
    applicants { {} }
    employer_name { Faker::Company.name }
    employment_title { Faker::Job.title }
    job_id { SecureRandom.uuid }
  end
end
