class JobPhotosController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize, only: %i[create destroy]
  before_action :set_job

  def create
    with_message_service do
      photo = Jobs::JobPhotosService.create(job, params[:job_photo][:photo_url])

      render json: photo
    end
  end

  def destroy
    photo = job.job_photos.find(params[:id])

    with_message_service do
      Jobs::JobPhotosService.destroy(photo)
    end

    render json: { success: true }
  end

  private

  attr_reader :job

  def set_job
    @job = Job.find(params[:job_id])
  end
end
