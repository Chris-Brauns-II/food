module Events
  module ChatCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          applicant_id Uuid
          profile_id Either(Uuid, nil), default: nil
          seeker_id Uuid
          user_id String
          employment_title String
        end
      end
    end

    module Data
      class V2
        extend Core::Payload

        schema do
          employer_id Uuid
          job_id Uuid
          seeker_id Uuid
          title String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Chats::CHAT_CREATED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Application,
      message_type: MessageTypes::Chats::CHAT_CREATED,
      version: 2
    )
  end
end
