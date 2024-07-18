FactoryBot.define do
  factory :invites__training_provider_invite, class: "Invites::TrainingProviderInvite" do
    id { SecureRandom.uuid }
    email { "fake@email.com" }
    first_name { "Training" }
    last_name { "Provider" }
    role_description { "A role" }
    training_provider_id { SecureRandom.uuid }
    training_provider_name { "SkillArc" }
    used_at { nil }
  end
end
