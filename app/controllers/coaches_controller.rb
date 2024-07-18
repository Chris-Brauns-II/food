class CoachesController < ApplicationController
  include Secured
  include CoachAuth

  before_action :authorize
  before_action :coach_authorize

  def index
    render json: Coaches::CoachesQuery.all_coaches
  end
end
