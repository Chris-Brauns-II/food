FactoryBot.define do
  factory :analytics__fact_job_visibility, class: "Analytics::FactJobVisibility" do
    dim_job factory: %i[analytics__dim_job]

    visible_starting_at { Time.zone.local(2018, 3, 3) }

    trait :hidden do
      visible_ending_at { Time.zone.local(2019, 3, 3) }
    end
  end
end
