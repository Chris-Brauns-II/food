module Commands
  module AssignCoach
    module Data
      class V1
        extend Core::Payload

        schema do
          coach_email String
        end
      end

      class V2
        extend Core::Payload

        schema do
          coach_id String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coaches::SeekerContext,
      message_type: MessageTypes::Coaches::ASSIGN_COACH,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Coaches::ASSIGN_COACH,
      version: 2
    )
  end
end
