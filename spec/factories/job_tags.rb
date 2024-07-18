FactoryBot.define do
  factory :job_tag do
    id { SecureRandom.uuid }

    job
    tag
  end
end
