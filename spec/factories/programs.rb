FactoryBot.define do
  factory :program do
    id { SecureRandom.uuid }
    training_provider

    name { "Welding" }
    description { "Learn to weld" }
  end
end
