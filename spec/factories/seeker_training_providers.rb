FactoryBot.define do
  factory :seeker_training_provider do
    id { SecureRandom.uuid }
    status { "Enrolled" }

    program
    training_provider
    seeker_id { create(:seeker).id }
  end
end
