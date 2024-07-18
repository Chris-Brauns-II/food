module Events
  module CoachAssigned
    module Data
      class V1
        extend Core::Payload

        schema do
          coach_id Uuid
          email String
        end
      end

      class V2
        extend Core::Payload

        schema do
          coach_id Uuid
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Coaches::COACH_ASSIGNED,
      version: 1
    )
    V2 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coaches::SeekerContext,
      message_type: MessageTypes::Coaches::COACH_ASSIGNED,
      version: 2
    )
    V3 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Coaches::COACH_ASSIGNED,
      version: 3
    )
  end
end
