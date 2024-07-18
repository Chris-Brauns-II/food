FactoryBot.define do
  factory :barrier do
    name { "A Barrier" }
    barrier_id { SecureRandom.uuid }
  end
end
