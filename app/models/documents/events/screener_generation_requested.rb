module Documents
  module Events
    module ScreenerGenerationRequested
      module Data
        class V1
          extend Core::Payload

          schema do
            screener_answers_id Uuid
            document_kind Either(*DocumentKind::ALL)
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::ScreenerDocument,
        message_type: MessageTypes::SCREENER_GENERATION_REQUESTED,
        version: 1
      )
    end
  end
end
