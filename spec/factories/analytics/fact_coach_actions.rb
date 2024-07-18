FactoryBot.define do
  factory :analytics__fact_coach_action, class: "Analytics::FactCoachAction" do
    dim_person_executor factory: %i[analytics__dim_person]
    dim_person_target factory: %i[analytics__dim_person]

    action { Analytics::FactCoachAction::Actions::NOTE_ADDED }
    action_taken_at { Time.zone.local(2023, 11, 5) }
  end
end
