FactoryBot.define do
  factory :analytics__dim_person, class: "Analytics::DimPerson" do
    kind { Analytics::DimPerson::Kind::SEEKER }
    first_name { "Chris" }
    last_name { "Brauns" }
    phone_number { "740-333-4444" }
    email { "some@email.com" }
    person_id { SecureRandom.uuid }
    person_added_at { Time.zone.local(2022, 1, 1) }

    trait :lead do
      kind { Analytics::DimPerson::Kind::LEAD }
    end

    trait :seeker do
      kind { Analytics::DimPerson::Kind::SEEKER }
      onboarding_completed_at { Time.zone.local(2023, 2, 1) }
    end
  end
end
