module Employers
  class ApplicantsController < ApplicationController
    include Secured
    include EmployerAuth
    include MessageEmitter

    before_action :authorize
    before_action :employer_authorize

    def update
      status = applicant_update_params[:status]
      reasons = applicant_update_params[:reasons]&.map(&:to_h)

      with_message_service do
        ApplicationService.update_status(
          status:,
          application_id: params[:id],
          message_service:,
          user_id: current_user.id,
          reasons: reasons || []
        )
      end

      head :accepted
    end

    def applicant_update_params
      params.permit(:status, reasons: %i[id response])
    end
  end
end
