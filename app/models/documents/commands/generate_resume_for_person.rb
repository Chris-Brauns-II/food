module Documents
  module Commands
    module GenerateResumeForPerson
      module Data
        class V1
          extend Core::Payload

          schema do
            person_id Uuid
            anonymized Bool()
            document_kind Either(*DocumentKind::ALL)
            page_limit 1..
          end
        end

        class V2
          extend Core::Payload

          schema do
            person_id Uuid
            anonymized Bool()
            checks ArrayOf(Either(*Checks::ALL))
            document_kind Either(*DocumentKind::ALL)
            page_limit 1..
          end
        end
      end

      V1 = Core::Schema.inactive(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V1,
        stream: Streams::ResumeDocument,
        message_type: MessageTypes::GENERATE_RESUME_FOR_PERSON,
        version: 1
      )
      V2 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V2,
        metadata: Core::RequestorMetadata::V1,
        stream: Streams::ResumeDocument,
        message_type: MessageTypes::GENERATE_RESUME_FOR_PERSON,
        version: 2
      )
    end
  end
end
