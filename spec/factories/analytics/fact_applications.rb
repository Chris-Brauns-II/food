FactoryBot.define do
  factory :analytics__fact_application, class: "Analytics::FactApplication" do
    dim_job factory: %i[analytics__dim_job]
    dim_person factory: %i[analytics__dim_person]

    status { "going_places" }
    application_id { SecureRandom.uuid }
    application_number { 1 }
    application_opened_at { Time.zone.local(2022, 1, 1) }
  end
end
