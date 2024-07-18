module Screeners
  class ScreenerController < ApplicationController
    include Secured

    before_action :authorize
    before_action :screener_authorize

    def requestor_metadata
      {
        requestor_type: Requestor::Kinds::USER,
        requestor_id: current_user.id,
        requestor_email: current_user.email
      }
    end

    def screener_authorize
      return if current_user.job_order_admin_role? || current_user.coach_role?

      render json: { error: 'Not authorized' }, status: :unauthorized
      nil
    end
  end
end
