module JobOrders
  class OrdersController < DashboardController
    include MessageEmitter

    def index
      render json: JobOrdersQuery.all_orders
    end

    def show
      render json: JobOrdersQuery.find_order(params[:id])
    end

    def create
      with_message_service do
        message_service.create!(
          schema: Commands::Add::V1,
          job_order_id: SecureRandom.uuid,
          trace_id: request.request_id,
          data: {
            job_id: params[:job_id]
          }
        )
      end

      failure = ::Projectors::Trace::GetFirst.project(trace_id: request.request_id, schema: JobOrders::Events::CreationFailed::V1)
      if failure.present?
        render json: { reason: failure.data.reason }, status: :bad_request
      else
        head :created
      end
    end

    def update
      with_message_service do
        JobOrders::JobOrdersReactor.new(message_service:).add_order_count(
          job_order_id: params[:id],
          order_count: params[:order_count],
          trace_id: request.request_id
        )
      end

      head :accepted
    end

    def activate
      with_message_service do
        message_service.create!(
          schema: Commands::Activate::V1,
          job_order_id: params[:order_id],
          trace_id: request.request_id,
          data: Core::Nothing
        )
      end

      failure = ::Projectors::Trace::GetFirst.project(trace_id: request.request_id, schema: JobOrders::Events::ActivationFailed::V1)
      if failure.present?
        render json: { reason: failure.data.reason }, status: :bad_request
      else
        head :accepted
      end
    end

    def close_not_filled
      with_message_service do
        JobOrders::JobOrdersReactor.new(message_service:).close_job_order_not_filled(
          job_order_id: params[:order_id],
          trace_id: request.request_id
        )
      end

      head :accepted
    end
  end
end
