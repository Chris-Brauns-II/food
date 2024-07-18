module JobOrders
  class JobsController < DashboardController
    def index
      render json: JobOrdersQuery.all_jobs
    end
  end
end
