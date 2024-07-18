class JobTagsController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize
  before_action :set_job

  def create
    tag = Tag.find_by!(name: params[:tag])

    with_message_service do
      render json: Jobs::JobTagService.create(job, tag)
    end
  end

  def destroy
    tag = job.job_tags.find(params[:id])

    with_message_service do
      Jobs::JobTagService.destroy(tag)
    end

    render json: { success: true }
  end

  private

  attr_reader :job

  def set_job
    @job = Job.find(params[:job_id])
  end
end
