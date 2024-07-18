FactoryBot.define do
  factory :job_attribute do
    attribute_id { SecureRandom.uuid }
    attribute_name { Faker::Lorem.word }
    job
  end
end
