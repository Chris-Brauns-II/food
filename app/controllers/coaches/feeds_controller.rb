module Coaches
  class FeedsController < ApplicationController
    include Secured
    include CoachAuth

    before_action :authorize
    before_action :coach_authorize

    def index
      render json: FeedEvent.all.map { |feed_event| feed_event.as_json(only: %i[id context_id description occurred_at seeker_email]) }
    end
  end
end
