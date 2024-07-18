FactoryBot.define do
  factory :analytics__dim_job, class: "Analytics::DimJob" do
    dim_employer factory: %i[analytics__dim_employer]

    category { "some cateogry" }
    employer_name { dim_employer.name }
    employment_title { "Best Job" }
    employment_type { "A type" }
    job_created_at { Time.zone.local(2020, 1, 1) }
    job_id { SecureRandom.uuid }
  end
end
