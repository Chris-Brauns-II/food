module Documents
  module Events
    module ResumeGenerationFailed
      module Data
        class V1
          extend Core::Payload

          schema do
            person_id Uuid
            anonymized Bool()
            document_kind Either(*DocumentKind::ALL)
            reason String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V1,
        stream: Streams::ResumeDocument,
        message_type: MessageTypes::RESUME_GENERATION_FAILED,
        version: 1
      )
    end
  end
end
