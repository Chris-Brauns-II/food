module Events
  module SeekerAttributeRemoved
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::SEEKER_ATTRIBUTE_REMOVED,
      version: 1
    )
  end
end
