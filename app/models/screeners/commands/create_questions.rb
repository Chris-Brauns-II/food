module Screeners
  module Commands
    module CreateQuestions
      module Data
        class V1
          extend Core::Payload

          schema do
            title String
            questions ArrayOf(String)
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::Questions,
        message_type: MessageTypes::CREATE_SCREENER_QUESTIONS,
        version: 1
      )
    end
  end
end
