module TrainingProviders
  class ProgramsController < ApplicationController
    include Secured
    include Admin
    include MessageEmitter

    before_action :authorize

    def create
      program_params = params.permit(:name, :description, :training_provider_id)

      with_message_service do
        message_service.create!(
          trace_id: request.request_id,
          training_provider_id: program_params[:training_provider_id],
          schema: Commands::CreateTrainingProviderProgram::V1,
          data: {
            program_id: SecureRandom.uuid,
            name: program_params[:name],
            description: program_params[:description]
          }
        )
      end

      head :created
    end
  end
end
