module Events
  module NoteModified
    module Data
      class V1
        extend Core::Payload

        schema do
          coach_id Uuid
          coach_email String
          note_id Uuid
          note String
        end
      end

      class V2
        extend Core::Payload

        schema do
          originator String
          note_id Uuid
          note String
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Coaches::NOTE_MODIFIED,
      version: 1
    )
    V2 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coaches::SeekerContext,
      message_type: MessageTypes::Coaches::NOTE_MODIFIED,
      version: 2
    )
    V3 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Coaches::SeekerContext,
      message_type: MessageTypes::Coaches::NOTE_MODIFIED,
      version: 3
    )
    V4 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Coaches::NOTE_MODIFIED,
      version: 4
    )
  end
end
