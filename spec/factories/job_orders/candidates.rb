FactoryBot.define do
  factory :job_orders__candidate, class: "JobOrders::Candidate" do
    job_order factory: %i[job_orders__job_order]
    person factory: %i[job_orders__person]

    applied_at { nil }
    added_at { Time.zone.local(2022, 1, 1) }
    status { JobOrders::CandidateStatus::ADDED }

    recommended_at { Time.zone.local(2023, 1, 1) }
    recommended_by { "khushi@skillarc.com" }

    trait :applied do
      applied_at { Time.zone.local(2024, 1, 1) }
    end
  end
end
