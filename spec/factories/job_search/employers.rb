FactoryBot.define do
  factory :job_search__employer, class: "JobSearch::Employer" do
    id { SecureRandom.uuid }
    logo_url { "www.google.com" }
  end
end
