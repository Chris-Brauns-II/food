class EmployersController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize

  def index
    render json: Employer.all
  end

  def show
    render json: Employer.find(params[:id])
  end

  def create
    employer_params = params.require(:employer).permit(:name, :bio, :logo_url, :location)

    with_message_service do
      message_service.create!(
        trace_id: request.request_id,
        employer_id: SecureRandom.uuid,
        schema: Commands::CreateEmployer::V1,
        data: {
          name: employer_params[:name],
          location: employer_params[:location],
          bio: employer_params[:bio],
          logo_url: employer_params[:logo_url]
        }
      )
    end

    head :created
  end

  def update
    employer_params = params.require(:employer).permit(:name, :bio, :logo_url, :location)

    with_message_service do
      message_service.create!(
        trace_id: request.request_id,
        employer_id: params[:id],
        schema: Commands::UpdateEmployer::V1,
        data: {
          name: employer_params[:name],
          location: employer_params[:location],
          bio: employer_params[:bio],
          logo_url: employer_params[:logo_url]
        }
      )
    end

    head :accepted
  end

  private

  def serialize_employer(employer)
    {
      id: employer.id,
      name: employer.name,
      location: employer.location,
      bio: employer.bio,
      logo_url: employer.logo_url,
      create_at: employer.create_at
    }
  end
end
