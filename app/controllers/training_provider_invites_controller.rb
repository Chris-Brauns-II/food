class TrainingProviderInvitesController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize, only: %i[index create]

  def index
    render json: Invites::TrainingProviderInvite.all.map { |invite| serialize_invite(invite) }
  end

  def create
    invite_params = params.require(:training_provider_invite).permit(:email, :first_name, :last_name, :role_description, :training_provider_id)

    with_message_service do
      message_service.create!(
        invite_id: SecureRandom.uuid,
        trace_id: request.request_id,
        schema: Commands::CreateTrainingProviderInvite::V1,
        data: {
          invite_email: invite_params[:email],
          first_name: invite_params[:first_name],
          last_name: invite_params[:last_name],
          role_description: invite_params[:role_description],
          training_provider_id: invite_params[:training_provider_id]
        }
      )
    end

    head :created
  end

  def used
    with_message_service do
      message_service.create!(
        invite_id: params[:training_provider_invite_id],
        trace_id: request.request_id,
        schema: Commands::AcceptTrainingProviderInvite::V1,
        data: {
          user_id: current_user.id
        }
      )
    end

    head :accepted
  end

  private

  def serialize_invite(invite)
    prefix = ENV.fetch('FRONTEND_URL', nil)

    {
      email: invite.email,
      first_name: invite.first_name,
      last_name: invite.last_name,
      role_description: invite.role_description,
      training_provider_name: invite.training_provider_name,
      training_provider_id: invite.training_provider_id,
      used_at: invite.used_at,
      link: "#{prefix}/invites/training_providers/#{invite.id}"
    }
  end
end
