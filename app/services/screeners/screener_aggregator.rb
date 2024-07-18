module Screeners
  class ScreenerAggregator < MessageConsumer
    def reset_for_replay
      Answers.delete_all
      Questions.delete_all
    end

    on_message Events::QuestionsCreated::V1 do |message|
      Questions.create!(
        id: message.stream.id,
        title: message.data.title,
        questions: message.data.questions
      )
    end

    on_message Events::QuestionsUpdated::V1 do |message|
      Questions.update!(
        message.stream.id,
        title: message.data.title,
        questions: message.data.questions
      )
    end

    on_message Events::AnswersCreated::V2 do |message|
      Answers.create!(
        id: message.stream.id,
        title: message.data.title,
        person_id: message.data.person_id,
        screeners_questions_id: message.data.screener_questions_id,
        question_responses: message.data.question_responses
      )
    end

    on_message Events::AnswersUpdated::V1 do |message|
      Answers.update!(
        message.stream.id,
        title: message.data.title,
        question_responses: message.data.question_responses
      )
    end
  end
end
