module Events
  module PersonViewed
    module Data
      class V1
        extend Core::Payload

        schema do
          person_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Person::PERSON_VIEWED,
      version: 1
    )
  end
end
