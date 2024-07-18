FactoryBot.define do
  factory :employers_job_owner, class: 'Employers::JobOwner' do
    job factory: %i[employers_job]
    recruiter factory: %i[employers_recruiter]
  end
end
