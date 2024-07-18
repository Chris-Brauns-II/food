FactoryBot.define do
  factory :training_provider do
    id { SecureRandom.uuid }

    name { "Megan's Recruits" }
    description { "We recruit and train the best!" }
  end
end
