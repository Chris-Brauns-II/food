FactoryBot.define do
  factory :profile_skill do
    id { SecureRandom.uuid }
    master_skill_id { create(:master_skill).id }
    seeker
  end
end
