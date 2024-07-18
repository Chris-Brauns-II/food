module Events
  module CoachAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          coach_id Uuid
          email String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Coaches::COACH_ADDED,
      version: 1
    )
  end
end
