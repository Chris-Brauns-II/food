class DesiredCertificationsController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize, only: %i[create destroy]

  def create
    with_message_service do
      message_service.create!(
        trace_id: request.request_id,
        job_id: params[:job_id],
        schema: Commands::AddDesiredCertification::V1,
        data: {
          id: SecureRandom.uuid,
          master_certification_id: params[:master_certification_id]
        }
      )
    end

    head :created
  end

  def destroy
    with_message_service do
      message_service.create!(
        trace_id: request.request_id,
        job_id: params[:job_id],
        schema: Commands::RemoveDesiredCertification::V1,
        data: {
          id: params[:id]
        }
      )
    end

    head :accepted
  end
end
