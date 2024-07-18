module Admin
  class AdminController < ApplicationController
    include Secured
    include Admin

    before_action :authorize, unless: -> { Rails.env.development? }
    before_action :admin_authorize, unless: -> { Rails.env.development? }
  end
end
