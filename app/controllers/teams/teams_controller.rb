module Teams
  class TeamsController < ApplicationController
    include Secured
    include MessageEmitter

    before_action :authorize

    def index
      render json: TeamsQuery.all_teams
    end
  end
end
