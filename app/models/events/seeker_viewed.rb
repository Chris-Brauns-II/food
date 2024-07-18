module Events
  module SeekerViewed
    module Data
      class V1
        extend Core::Payload

        schema do
          seeker_id Uuid
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Seekers::SEEKER_VIEWED,
      version: 1
    )
  end
end
