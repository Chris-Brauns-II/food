module JobOrders
  module Commands
    module Activate
      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Core::Nothing,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::ACTIVATE_JOB_ORDER,
        version: 1
      )
    end
  end
end
