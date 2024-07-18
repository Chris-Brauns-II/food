class TrainingProvidersController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize, only: [:create]

  def index
    render json: TrainingProvider.includes(:programs).map { |tp| serialize_training_provider(tp) }
  end

  def show
    render json: serialize_training_provider(TrainingProvider.find(params[:id]))
  end

  def create
    training_provider_params = params.require(:training_provider).permit(:name, :description)

    with_message_service do
      message_service.create!(
        trace_id: request.request_id,
        training_provider_id: SecureRandom.uuid,
        schema: Commands::CreateTrainingProvider::V1,
        data: {
          name: training_provider_params[:name],
          description: training_provider_params[:description]
        }
      )
    end

    head :created
  end

  private

  def serialize_training_provider(tp)
    {
      id: tp.id,
      name: tp.name,
      description: tp.description,
      programs: tp.programs.map do |program|
        {
          id: program.id,
          name: program.name,
          description: program.description
        }
      end
    }
  end
end
