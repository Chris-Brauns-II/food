module Documents
  module Commands
    module GenerateScreener
      module Data
        class V1
          extend Core::Payload

          schema do
            person_id Uuid
            screener_answers_id Uuid
            title String
            question_responses ArrayOf(Screeners::QuestionResponse)
            document_kind Either(*DocumentKind::ALL)
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::ScreenerDocument,
        message_type: MessageTypes::GENERATE_SCREENER,
        version: 1
      )
    end
  end
end
