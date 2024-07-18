class MasterCertificationsController < ApplicationController
  include Secured
  include Admin

  before_action :authorize
  before_action :admin_authorize

  def index
    render json: MasterCertification.all
  end
end
