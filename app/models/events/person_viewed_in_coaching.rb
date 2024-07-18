module Events
  module PersonViewedInCoaching
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
      stream: Streams::Coach,
      message_type: MessageTypes::Coaches::PERSON_VIEWED_IN_COACHING,
      version: 1
    )
  end
end
