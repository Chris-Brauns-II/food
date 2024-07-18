module Events
  module ReasonCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          description String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::REASON_CREATED,
      version: 1
    )
  end
end
