module Screeners
  module Events
    module AnswersCreated
      module Data
        class V1
          extend Core::Payload

          schema do
            title String
            screener_questions_id Uuid
            question_responses ArrayOf(QuestionResponse)
          end
        end

        class V2
          extend Core::Payload

          schema do
            title String
            person_id Uuid
            screener_questions_id Uuid
            question_responses ArrayOf(QuestionResponse)
          end
        end
      end

      V1 = Core::Schema.inactive(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::Answers,
        message_type: MessageTypes::SCREENER_ANSWERS_CREATED,
        version: 1
      )
      V2 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V2,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::Answers,
        message_type: MessageTypes::SCREENER_ANSWERS_CREATED,
        version: 2
      )
    end
  end
end
