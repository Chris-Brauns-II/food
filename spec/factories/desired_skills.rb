FactoryBot.define do
  factory :desired_skill do
    id { SecureRandom.uuid }
    master_skill_id { create(:master_skill).id }
    job
  end
end
