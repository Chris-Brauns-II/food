module Events
  module ApplicantStatusUpdated
    module Reason
      class V1
        extend Core::Payload

        schema do
          id Uuid
          response Either(String, nil)
        end
      end

      class V2
        extend Core::Payload

        schema do
          id Uuid
          reason_description String
          response Either(String, nil)
        end
      end
    end

    module Data
      class V1
        extend Core::Payload

        schema do
          applicant_id Uuid
          profile_id Either(Uuid, nil), default: nil
          seeker_id Uuid
          user_id String
          job_id Uuid
          employer_name String
          employment_title String
          status Either(*ApplicantStatus::StatusTypes::ALL)
        end
      end

      class V2
        extend Core::Payload

        schema do
          applicant_id Uuid
          applicant_first_name String
          applicant_last_name String
          applicant_email String
          applicant_phone_number Either(String, nil), default: nil
          profile_id Either(Uuid, nil), default: nil
          seeker_id Uuid
          user_id String
          job_id Uuid
          employer_name String
          employment_title String
          status Either(*ApplicantStatus::StatusTypes::ALL)
        end
      end

      class V3
        extend Core::Payload

        schema do
          applicant_id Uuid
          applicant_first_name String
          applicant_last_name String
          applicant_email String
          applicant_phone_number Either(String, nil), default: nil
          profile_id Either(Uuid, nil), default: nil
          seeker_id Uuid
          user_id String
          job_id Uuid
          employer_name String
          employment_title String
          status Either(*ApplicantStatus::StatusTypes::ALL)
          reasons ArrayOf(Reason::V1), default: []
        end
      end

      class V4
        extend Core::Payload

        schema do
          applicant_id Uuid
          applicant_first_name String
          applicant_last_name String
          applicant_email String
          applicant_phone_number Either(String, nil), default: nil
          profile_id Either(Uuid, nil), default: nil
          seeker_id Uuid
          user_id String
          job_id Uuid
          employer_name String
          employment_title String
          status Either(*ApplicantStatus::StatusTypes::ALL)
          reasons ArrayOf(Reason::V2), default: []
        end
      end

      class V5
        extend Core::Payload

        schema do
          applicant_first_name String
          applicant_last_name String
          applicant_email String
          applicant_phone_number Either(String, nil), default: nil
          seeker_id Uuid
          user_id String
          job_id Uuid
          employer_name String
          employment_title String
          status Either(*ApplicantStatus::StatusTypes::ALL)
          reasons ArrayOf(Reason::V2), default: []
        end
      end
    end

    module MetaData
      class V1
        extend Core::Payload

        schema do
          user_id Either(String, nil), default: nil
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::APPLICANT_STATUS_UPDATED,
      version: 1
    )

    V2 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::APPLICANT_STATUS_UPDATED,
      version: 2
    )

    V3 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V3,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::APPLICANT_STATUS_UPDATED,
      version: 3
    )

    V4 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V4,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::APPLICANT_STATUS_UPDATED,
      version: 4
    )

    V5 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V4,
      metadata: MetaData::V1,
      stream: Streams::Job,
      message_type: MessageTypes::APPLICANT_STATUS_UPDATED,
      version: 5
    )

    V6 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V5,
      metadata: MetaData::V1,
      stream: Streams::Application,
      message_type: MessageTypes::APPLICANT_STATUS_UPDATED,
      version: 6
    )
  end
end
