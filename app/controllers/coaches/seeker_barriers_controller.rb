module Coaches
  class SeekerBarriersController < ApplicationController
    include Secured
    include CoachAuth
    include MessageEmitter

    before_action :authorize
    before_action :coach_authorize

    def update_all
      with_message_service do
        CoachesEventEmitter.new(message_service:).update_barriers(
          person_id: params[:context_id],
          barriers: params[:barriers],
          trace_id: request.request_id
        )
      end

      head :accepted
    end
  end
end
