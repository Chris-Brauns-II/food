module Events
  module ChatMessageSent
    module Data
      class V1
        extend Core::Payload

        schema do
          applicant_id Uuid
          profile_id Either(Uuid, nil), default: nil
          seeker_id Uuid
          from_user_id String
          employer_name String
          employment_title String
          message String
        end
      end

      class V2
        extend Core::Payload

        schema do
          from_name String
          from_user_id Either(String, nil)
          message String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Chats::CHAT_MESSAGE_SENT,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Application,
      message_type: MessageTypes::Chats::CHAT_MESSAGE_SENT,
      version: 2
    )
  end
end
