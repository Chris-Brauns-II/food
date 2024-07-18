class ProgramsController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize

  def show
    program = Program.find(params[:id])
    render json: serialize_program(program)
  end

  def update
    program_params = params.permit(:id, :name, :description, :training_provider_id)

    with_message_service do
      message_service.create!(
        trace_id: request.request_id,
        training_provider_id: program_params[:training_provider_id],
        schema: Commands::UpdateTrainingProviderProgram::V1,
        data: {
          program_id: program_params[:id],
          name: program_params[:name],
          description: program_params[:description]
        }
      )
    end

    head :accepted
  end

  private

  def serialize_program(program)
    {
      name: program.name,
      description: program.description,
      training_provider_id: program.training_provider_id,
      training_provider_name: program.training_provider.name
    }
  end
end
