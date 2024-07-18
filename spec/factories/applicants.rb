FactoryBot.define do
  factory :applicant do
    id { SecureRandom.uuid }
    job_id { SecureRandom.uuid }
    seeker

    applicant_statuses do
      [
        build(:applicant_status, :new)
      ]
    end
  end
end
