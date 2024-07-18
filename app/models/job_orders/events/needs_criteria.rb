module JobOrders
  module Events
    module NeedsCriteria
      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Core::Nothing,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::JOB_ORDER_NEEDS_CRITERIA,
        version: 1
      )
    end
  end
end
