module JobOrders
  module Events
    module NoteModified
      module Data
        class V1
          extend Core::Payload

          schema do
            originator String
            note_id Uuid
            note String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::JOB_ORDER_NOTE_MODIFIED,
        version: 1
      )
    end
  end
end
