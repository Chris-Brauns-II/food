FactoryBot.define do
  factory :job_search__saved_job, class: "JobSearch::SavedJob" do
    search_job factory: %i[job_search__job]
    user_id { SecureRandom.uuid }
  end
end
