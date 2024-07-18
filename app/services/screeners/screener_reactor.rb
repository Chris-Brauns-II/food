module Screeners
  class ScreenerReactor < MessageReactor
    def can_replay?
      true
    end

    on_message Commands::CreateAnswers::V2 do |message|
      return unless ::Projectors::Streams::HasOccurred.project(
        stream: Streams::Questions.new(screener_questions_id: message.data.screener_questions_id),
        schema: Events::QuestionsCreated::V1
      )

      message_service.create_once_for_stream!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::AnswersCreated::V2,
        data: {
          title: message.data.title,
          person_id: message.data.person_id,
          screener_questions_id: message.data.screener_questions_id,
          question_responses: message.data.question_responses
        },
        metadata: message.metadata
      )
    end

    on_message Commands::UpdateAnswers::V1 do |message|
      return unless ::Projectors::Streams::HasOccurred.project(stream: message.stream, schema: Events::AnswersCreated::V2)

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::AnswersUpdated::V1,
        data: {
          title: message.data.title,
          question_responses: message.data.question_responses
        },
        metadata: message.metadata
      )
    end

    on_message Commands::CreateQuestions::V1 do |message|
      message_service.create_once_for_stream!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::QuestionsCreated::V1,
        data: {
          title: message.data.title,
          questions: message.data.questions
        },
        metadata: message.metadata
      )
    end

    on_message Commands::UpdateQuestions::V1 do |message|
      return unless ::Projectors::Streams::HasOccurred.project(stream: message.stream, schema: Events::QuestionsCreated::V1)

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::QuestionsUpdated::V1,
        data: {
          title: message.data.title,
          questions: message.data.questions
        },
        metadata: message.metadata
      )
    end
  end
end
