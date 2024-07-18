FactoryBot.define do
  factory :employers_job, class: 'Employers::Job' do
    employer factory: %i[employers_employer]

    job_id { SecureRandom.uuid }
    benefits_description { Faker::Lorem.sentence }
    employment_title { Faker::Job.title }
    employment_type { "Full-time" }
    hide_job { false }
    location { Faker::Address.city }
    requirements_description { Faker::Lorem.sentence }
    responsibilities_description { Faker::Lorem.sentence }
    schedule { "9-5" }
    work_days { "Monday-Friday" }
  end
end
