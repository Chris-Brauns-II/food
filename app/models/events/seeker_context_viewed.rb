module Events
  module SeekerContextViewed
    module Data
      class V1
        extend Core::Payload

        schema do
          context_id String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coach,
      message_type: MessageTypes::Seekers::SEEKER_CONTEXT_VIEWED,
      version: 1
    )
  end
end
