module Admin
  class UsersController < AdminController
    def index
      render json: User.all
    end
  end
end
