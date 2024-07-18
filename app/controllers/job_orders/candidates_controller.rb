module JobOrders
  class CandidatesController < DashboardController
    include MessageEmitter

    def update
      job_order_id = params[:order_id]
      status = params[:status]

      with_message_service do
        JobOrders::JobOrdersReactor.new(message_service:).update_status(
          job_order_id:,
          person_id: params[:id],
          status:,
          trace_id: request.request_id
        )
      end
    end
  end
end
