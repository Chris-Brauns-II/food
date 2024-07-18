class UsersController < ApplicationController
  include Secured
  include CoachAuth
  include MessageEmitter

  before_action :authorize
  before_action :authorize_is_user_or_coach
  before_action :set_user, only: [:update]

  def update
    with_message_service do
      render json: People::BasicInfoService.new(user.id, message_service).update(
        **user_params.to_h.symbolize_keys,
        email: current_user.email
      )
    end
  end

  private

  attr_reader :user

  def authorize_is_user_or_coach
    render json: {}, status: :unauthorized unless current_user.id == params[:id] || coach?
  end

  def user_params
    params.permit(:about, :first_name, :last_name, :phone_number, :zip_code)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
