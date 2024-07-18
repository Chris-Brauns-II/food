module JobOrders
  module Events
    module ActivationFailed
      module Data
        class V1
          extend Core::Payload

          schema do
            reason String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::JOB_ORDER_ACTIVATION_FAILED,
        version: 1
      )
    end
  end
end
