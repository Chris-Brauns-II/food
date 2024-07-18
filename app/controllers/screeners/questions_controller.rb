module Screeners
  class QuestionsController < ScreenerController
    include MessageEmitter

    def index
      render json: Screeners::ScreenerQuery.all_questions
    end

    def show
      render json: Screeners::ScreenerQuery.find_questions(params[:id])
    end

    def create
      with_message_service do
        message_service.create!(
          trace_id: request.request_id,
          screener_questions_id: SecureRandom.uuid,
          schema: Commands::CreateQuestions::V1,
          data: {
            title: params[:title],
            questions: params[:questions]
          },
          metadata: requestor_metadata
        )
      end

      head :created
    end

    def update
      with_message_service do
        message_service.create!(
          trace_id: request.request_id,
          screener_questions_id: params[:id],
          schema: Commands::UpdateQuestions::V1,
          data: {
            title: params[:title],
            questions: params[:questions]
          },
          metadata: requestor_metadata
        )
      end

      head :accepted
    end
  end
end
