class EmployerInvitesController < ApplicationController
  include Secured
  include Admin
  include MessageEmitter

  before_action :authorize
  before_action :admin_authorize, only: %i[index create]

  def index
    render json: Invites::EmployerInvite.all.map { |invite| serialize_invite(invite) }
  end

  def create
    with_message_service do
      invite_params = params.require(:employer_invite).permit(:email, :employer_id, :first_name, :last_name).to_h.symbolize_keys

      message_service.create!(
        schema: Commands::CreateEmployerInvite::V1,
        trace_id: request.request_id,
        invite_id: SecureRandom.uuid,
        data: {
          invite_email: invite_params[:email],
          employer_id: invite_params[:employer_id],
          first_name: invite_params[:first_name],
          last_name: invite_params[:last_name]
        }
      )
    end

    head :created
  end

  def used
    with_message_service do
      message_service.create!(
        schema: Commands::AcceptEmployerInvite::V1,
        trace_id: request.request_id,
        invite_id: params[:employer_invite_id],
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
      used_at: invite.used_at,
      employer_name: invite.employer_name,
      link: "#{prefix}/invites/employers/#{invite.id}"
    }
  end
end
