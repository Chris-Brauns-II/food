module Screeners
  module Events
    module QuestionsCreated
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
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::Questions,
        message_type: MessageTypes::SCREENER_QUESTIONS_CREATED,
        version: 1
      )
    end
  end
end
