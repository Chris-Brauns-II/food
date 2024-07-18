module JobOrders
  class NotesController < DashboardController
    include MessageEmitter

    def create
      with_message_service do
        JobOrders::JobOrdersReactor.new(message_service:).add_note(
          job_order_id: params[:order_id],
          originator: current_user.email,
          note_id: SecureRandom.uuid,
          note: params[:note],
          trace_id: request.request_id
        )
      end

      head :created
    end

    def update
      with_message_service do
        JobOrders::JobOrdersReactor.new(message_service:).modify_note(
          job_order_id: params[:order_id],
          originator: current_user.email,
          note_id: params[:id],
          note: params[:note],
          trace_id: request.request_id
        )
      end

      head :accepted
    end

    def destroy
      with_message_service do
        JobOrders::JobOrdersReactor.new(message_service:).remove_note(
          job_order_id: params[:order_id],
          originator: current_user.email,
          note_id: params[:id],
          trace_id: request.request_id
        )
      end

      head :accepted
    end
  end
end
