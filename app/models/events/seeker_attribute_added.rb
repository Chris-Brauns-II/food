module Events
  module SeekerAttributeAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          attribute_id Uuid
          attribute_name String
          attribute_values ArrayOf(String)
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::SEEKER_ATTRIBUTE_ADDED,
      version: 1
    )
  end
end
