module Coaches
  class LeadsController < ApplicationController
    include Secured
    include CoachAuth
    include MessageEmitter

    before_action :authorize
    before_action :coach_authorize
    before_action :set_coach

    def index
      render json: CoachesQuery.all_leads
    end

    def create
      lead = params.require(:lead).permit(
        :lead_id,
        :email,
        :phone_number,
        :first_name,
        :last_name
      ).to_h.symbolize_keys

      with_message_service do
        message_service.create!(
          person_id: SecureRandom.uuid,
          trace_id: request.request_id,
          schema: Commands::AddPerson::V2,
          data: {
            user_id: nil,
            date_of_birth: nil,
            email: lead[:email],
            phone_number: lead[:phone_number],
            first_name: lead[:first_name],
            last_name: lead[:last_name],
            source_kind: People::SourceKind::COACH,
            source_identifier: coach.id
          }
        )
      end

      head :created
    end

    private

    attr_reader :coach

    def set_coach
      @coach = Coach.find_by(user_id: current_user.id)
    end
  end
end
