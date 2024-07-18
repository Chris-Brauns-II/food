module Events
  module SeekerApplied
    module Data
      class V1
        extend Core::Payload

        schema do
          seeker_first_name String
          seeker_last_name String
          seeker_email String
          seeker_phone_number Either(String, nil), default: nil
          seeker_id Uuid
          job_id Uuid
          employer_name String
          employment_title String
        end
      end

      class V2
        extend Core::Payload

        schema do
          application_id Uuid
          seeker_first_name String
          seeker_last_name String
          seeker_email String
          seeker_phone_number Either(String, nil), default: nil
          user_id String
          job_id Uuid
          employer_name String
          employment_title String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::SEEKER_APPLIED,
      version: 1
    )
    V2 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::SEEKER_APPLIED,
      version: 2
    )
  end
end
