FactoryBot.define do
  factory :analytics__fact_candidate, class: "Analytics::FactCandidate" do
    dim_job_order factory: %i[analytics__dim_job_order]
    dim_person factory: %i[analytics__dim_person]

    first_name { dim_person.first_name }
    last_name { dim_person.last_name }
    email { dim_person.email }

    employment_title { dim_job_order.employment_title }
    employer_name { dim_job_order.employer_name }
    status { "waiting on popcorn" }
    terminal_status_at { nil }
    order_candidate_number { 1 }
    added_at { Time.zone.local(2022, 1, 1) }
  end
end
