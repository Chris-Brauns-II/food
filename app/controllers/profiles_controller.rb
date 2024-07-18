class ProfilesController < ApplicationController
  include Secured
  include SeekerAuth
  include MessageEmitter

  before_action :set_seeker, only: %i[show]
  before_action :set_current_user, only: [:show]

  def show
    with_message_service do
      render json: SeekerService.new(seeker).get(user_id: current_user&.id, seeker_editor: seeker_editor?)
    end
  end

  private

  attr_reader :seeker

  def set_seeker
    @seeker = Seeker.includes(:profile_skills).find(params[:id])
  end
end
