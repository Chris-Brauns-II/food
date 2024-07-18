module Seekers
  class ChatsController < ApplicationController
    include Secured
    include MessageEmitter

    before_action :authorize
    before_action :set_seeker, only: %i[mark_read send_message]

    def index
      if current_user.seeker.present?
        with_message_service do
          render json: SeekerChats.new(seeker: current_user.seeker, message_service:).get
        end
      else
        render json: []
      end
    end

    def mark_read
      with_message_service do
        SeekerChats.new(seeker:, message_service:).mark_read(
          application_id: params[:applicant_id]
        )
      end

      head :accepted
    end

    def send_message
      with_message_service do
        SeekerChats.new(seeker:, message_service:).send_message(
          application_id: params[:applicant_id],
          message: params[:message]
        )
      end

      head :accepted
    end

    private

    attr_reader :seeker

    def set_seeker
      render json: { message: "No seeker" }, status: :bad_request if current_user.seeker.blank?
      @seeker = current_user.seeker
    end
  end
end
