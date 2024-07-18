module JobOrders
  module Events
    module CriteriaAdded
      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Core::Nothing,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::JOB_ORDER_CRITERIA_ADDED,
        version: 1
      )
    end
  end
end
