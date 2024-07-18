FactoryBot.define do
  factory :coaches__job, class: "Coaches::Job" do
    employment_title { Faker::Job.title }
    job_id { SecureRandom.uuid }
    hide_job { false }
  end
end
