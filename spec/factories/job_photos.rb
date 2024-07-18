FactoryBot.define do
  factory :job_photo do
    id { SecureRandom.uuid }
    job

    photo_url { "https://www.example.com" }
  end
end
