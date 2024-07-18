FactoryBot.define do
  factory :applicant_status do
    id { SecureRandom.uuid }

    trait :new do
      status { ApplicantStatus::StatusTypes::NEW }
    end

    trait :pending_intro do
      status { ApplicantStatus::StatusTypes::PENDING_INTRO }
    end

    trait :intro_made do
      status { ApplicantStatus::StatusTypes::INTRO_MADE }
    end

    trait :interviewing do
      status { ApplicantStatus::StatusTypes::INTERVIEWING }
    end
  end
end
