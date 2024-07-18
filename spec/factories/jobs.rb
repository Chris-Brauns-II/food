FactoryBot.define do
  factory :job do
    id { SecureRandom.uuid }
    employer

    category { Job::Categories::STAFFING }
    benefits_description { "We have benefits." }
    employment_title { "Welder" }
    industry { ["manufacturing"] }
    location { "Columbus, OH" }
    employment_type { "FULLTIME" }
  end
end
