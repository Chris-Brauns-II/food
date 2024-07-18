FactoryBot.define do
  factory :learned_skill do
    id { SecureRandom.uuid }
    master_skill_id { create(:master_skill).id }
    job
  end
end
