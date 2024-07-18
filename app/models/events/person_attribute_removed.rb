module Events
  module PersonAttributeRemoved
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_ATTRIBUTE_REMOVED,
      version: 1
    )
  end
end
