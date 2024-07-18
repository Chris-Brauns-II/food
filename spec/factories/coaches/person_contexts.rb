FactoryBot.define do
  factory :coaches__person_context, class: "Coaches::PersonContext" do
    user_id { SecureRandom.uuid }
    kind { Coaches::PersonContext::Kind::SEEKER }
    person_captured_at { Time.zone.local(2020, 1, 1) }
    assigned_coach { SecureRandom.uuid }
    certified_by { "jim@cool.com" }
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    barriers { [] }

    trait :lead do
      kind { Coaches::PersonContext::Kind::LEAD }
    end

    trait :seeker do
      kind { Coaches::PersonContext::Kind::SEEKER }
    end
  end
end
