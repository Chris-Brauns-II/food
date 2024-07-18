class CareerPathsController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize, only: %i[create destroy]
  before_action :set_job
  before_action :set_path, only: %i[destroy up down]

  def up
    with_message_service do
      Jobs::CareerPathService.up(path)
    end

    render json: { success: true }
  end

  def down
    with_message_service do
      Jobs::CareerPathService.down(path)
    end

    render json: { success: true }
  end

  def create
    with_message_service do
      render json: Jobs::CareerPathService.create(
        job,
        **params.require(:career_path).permit(:title, :lower_limit, :upper_limit).to_h.symbolize_keys
      )
    end
  end

  def destroy
    with_message_service do
      Jobs::CareerPathService.destroy(path)

      render json: { success: true }
    end
  end

  private

  attr_reader :job, :path

  def set_job
    @job = Job.find(params[:job_id])
  end

  def set_path
    @path = job.career_paths.find(params[:id] || params[:career_path_id])
  end
end
