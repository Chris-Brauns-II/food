module JobOrders
  module Events
    module TeamResponsibleForStatus
      module Data
        class V1
          extend Core::Payload

          schema do
            team_id Uuid
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::OrderStatus,
        message_type: MessageTypes::JOB_ORDER_TEAM_RESPONSIBLE_FOR_STATUS,
        version: 1
      )
    end
  end
end
