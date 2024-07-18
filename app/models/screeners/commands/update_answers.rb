module Screeners
  module Commands
    module UpdateAnswers
      module Data
        class V1
          extend Core::Payload

          schema do
            title String
            question_responses ArrayOf(QuestionResponse)
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::Answers,
        message_type: MessageTypes::UPDATE_SCREENER_ANSWERS,
        version: 1
      )
    end
  end
end
