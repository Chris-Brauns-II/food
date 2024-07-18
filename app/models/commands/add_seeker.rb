module Commands
  module AddSeeker
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
        end
      end

      class V2
        extend Core::Payload

        schema do
          user_id Uuid
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Seekers::ADD_SEEKER,
      version: 1
    )
    V2 = Core::Schema.destroy!(
      type: Core::COMMAND,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::ADD_SEEKER,
      version: 2
    )
  end
end
