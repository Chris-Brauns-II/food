FactoryBot.define do
  factory :analytics__fact_person_viewed, class: "Analytics::FactPersonViewed" do
    dim_person_viewed factory: %i[analytics__dim_person]
    dim_person_viewer factory: %i[analytics__dim_person]

    viewed_at { Time.zone.local(2022, 4, 1) }
  end
end
