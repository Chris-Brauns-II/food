module JobOrders
  class DashboardController < ApplicationController
    include Secured

    before_action :authorize
    before_action :job_order_authorize

    def job_order_authorize
      return if current_user.job_order_admin_role?

      render json: { error: 'Not authorized' }, status: :unauthorized
      nil
    end
  end
end
