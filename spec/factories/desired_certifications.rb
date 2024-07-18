FactoryBot.define do
  factory :desired_certification do
    id { SecureRandom.uuid }
    master_certification_id { create(:master_certification).id }
    job
  end
end
