FactoryBot.define do
  factory :master_skill do
    id { SecureRandom.uuid }

    skill { "This is a skill" }
    type { "PERSONAL" }
  end
end
