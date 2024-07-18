class MainController < ApplicationController
  def index
    @logged_in = session[:userinfo].present?
  end
end
