module Commands
  module SendMessage
    module Data
      class V1
        extend Core::Payload

        schema do
          user_id String
          title String
          body String
          url Either(String, nil)
        end
      end

      class V2
        extend Core::Payload

        schema do
          person_id Uuid
          title String
          body String
          url Either(String, nil)
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::RequestorMetadata::V1,
      stream: Streams::Message,
      message_type: MessageTypes::Contact::SEND_MESSAGE,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V2,
      metadata: Core::RequestorMetadata::V1,
      stream: Streams::Message,
      message_type: MessageTypes::Contact::SEND_MESSAGE,
      version: 2
    )
  end
end
