module Documents
  module Events
    module ScreenerGenerated
      module Data
        class V1
          extend Core::Payload

          schema do
            person_id Uuid
            screener_answers_id Uuid
            document_kind Either(*DocumentKind::ALL)
            storage_kind Either(*StorageKind::ALL)
            storage_identifier String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::ScreenerDocument,
        message_type: MessageTypes::SCREENER_GENERATED,
        version: 1
      )
    end
  end
end
