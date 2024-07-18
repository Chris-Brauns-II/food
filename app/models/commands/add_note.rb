module Commands
  module AddNote
    module Data
      class V1
        extend Core::Payload

        schema do
          originator String
          note String
          note_id Uuid
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coaches::SeekerContext,
      message_type: MessageTypes::Coaches::ADD_NOTE,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Coaches::ADD_NOTE,
      version: 2
    )
  end
end
