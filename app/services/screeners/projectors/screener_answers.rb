module Screeners
  module Projectors
    class ScreenerAnswers < Projector
      projection_stream Streams::Answers

      class Projection
        extend Record

        schema do
          title Either(String, nil)
          person_id Either(Uuid, nil)
          question_responses ArrayOf(QuestionResponse)
        end
      end

      def init
        Projection.new(
          title: nil,
          person_id: nil,
          question_responses: []
        )
      end

      on_message Events::AnswersCreated::V2 do |message, accumulator|
        accumulator.with(
          title: message.data.title,
          person_id: message.data.person_id,
          question_responses: message.data.question_responses
        )
      end

      on_message Events::AnswersUpdated::V1 do |message, accumulator|
        accumulator.with(
          title: message.data.title,
          question_responses: message.data.question_responses
        )
      end
    end
  end
end
