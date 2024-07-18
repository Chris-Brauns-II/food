module Coaches
  class JobOrdersController < ApplicationController
    include Secured
    include CoachAuth
    include MessageEmitter

    before_action :authorize
    before_action :coach_authorize

    def index
      render json: JobOrders::JobOrdersQuery.all_active_orders
    end

    def recommend
      job_order_id = params[:job_order_id]
      person_id = params[:seeker_id]

      with_message_service do
        message_service.create!(
          trace_id: request.request_id,
          job_order_id:,
          schema: JobOrders::Commands::AddCandidate::V2,
          data: {
            person_id:
          },
          metadata: {
            requestor_id: current_user.id,
            requestor_email: current_user.email,
            requestor_type: Requestor::Kinds::COACH
          }
        )
      end

      head :accepted
    end
  end
end
