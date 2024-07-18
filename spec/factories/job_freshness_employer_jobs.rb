FactoryBot.define do
  factory :job_freshness_employer_job do
    employer_id { SecureRandom.uuid }
    name { Faker::Job.title }
  end
end
