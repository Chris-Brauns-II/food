module Events
  module ProfileCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          user_id String
        end
      end

      class V2
        extend Core::Payload

        schema do
          user_id String
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Seekers::PROFILE_CREATED,
      version: 1
    )
  end
end
