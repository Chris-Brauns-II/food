module Events
  module PersonAttributeAdded
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

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_ATTRIBUTE_ADDED,
      version: 1
    )
  end
end
