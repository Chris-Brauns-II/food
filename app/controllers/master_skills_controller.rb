class MasterSkillsController < ApplicationController
  def index
    render json: MasterSkill.all
  end
end
