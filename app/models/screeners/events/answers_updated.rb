module Screeners
  module Events
    module AnswersUpdated
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
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::Answers,
        message_type: MessageTypes::SCREENER_ANSWERS_UPDATED,
        version: 1
      )
    end
  end
end
