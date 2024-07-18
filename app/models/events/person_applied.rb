module Events
  module PersonApplied
    module Data
      class V1
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

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_APPLIED,
      version: 1
    )
  end
end
