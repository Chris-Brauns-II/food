module Documents
  module Events
    module ScreenerGenerationFailed
      module Data
        class V1
          extend Core::Payload

          schema do
            person_id Either(Uuid, nil)
            screener_answers_id Uuid
            document_kind Either(*DocumentKind::ALL)
            reason String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::ScreenerDocument,
        message_type: MessageTypes::SCREENER_GENERATION_FAILED,
        version: 1
      )
    end
  end
end
