class DesiredSkillsController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize, only: %i[create destroy]
  before_action :set_job

  def create
    with_message_service do
      render json: Jobs::DesiredSkillService.create(job, params[:master_skill_id])
    end
  end

  def destroy
    desired_skill = job.desired_skills.find(params[:id])

    with_message_service do
      Jobs::DesiredSkillService.destroy(desired_skill)
    end

    render json: { success: true }
  end

  private

  attr_reader :job

  def set_job
    @job = Job.find(params[:job_id])
  end
end
