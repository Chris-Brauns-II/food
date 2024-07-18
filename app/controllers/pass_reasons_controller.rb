class PassReasonsController < ApplicationController
  include Secured
  include EmployerAuth

  before_action :authorize
  before_action :employer_authorize

  def index
    render json: Employers::PassReason.all
  end
end
