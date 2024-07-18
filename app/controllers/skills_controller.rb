class SkillsController < ApplicationController
  include Secured
  include SeekerAuth
  include MessageEmitter

  before_action :authorize
  before_action :set_seeker
  before_action :seeker_editor_authorize
  before_action :set_skill, only: %i[update destroy]

  def create
    with_message_service do
      Seekers::SkillService.new(seeker).create(
        **params.require(:skill).permit(:description, :master_skill_id).to_h.symbolize_keys
      )

      head :created
    end
  end

  def update
    with_message_service do
      render json: Seekers::SkillService.new(seeker).update(skill, description: params[:skill][:description])
    end

    head :accepted
  end

  def destroy
    with_message_service do
      Seekers::SkillService.new(seeker).destroy(skill)
    end

    head :accepted
  end

  private

  attr_reader :seeker, :skill

  def set_skill
    @skill = ProfileSkill.find(params[:id])
  end

  def set_seeker
    @seeker = Seeker.includes(:profile_skills).find(params[:profile_id])
  end
end
